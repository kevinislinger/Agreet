// Edge Function to notify users of a match
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Define types
interface WebhookPayload {
  type: string;
  table: string;
  record: {
    id: string;
    status: string;
    matched_option_id: string;
    matched_at: string;
  };
  schema: string;
  old_record: {
    id: string;
    status: string;
    matched_option_id: string | null;
    matched_at: string | null;
  };
}

interface NotificationData {
  title: string;
  body: string;
  data: {
    sessionId: string;
    optionId: string;
  };
}

// Helper function to create JWT for APNS authentication
async function createAPNSJWT(): Promise<string> {
  const teamId = Deno.env.get("APPLE_TEAM_ID");
  const keyId = Deno.env.get("APNS_KEY_ID");
  const p8CertificateBase64 = Deno.env.get("APNS_P8_CERTIFICATE");

  console.log("Creating APNS JWT with:");
  console.log("- Team ID:", teamId ? `${teamId.substring(0, 4)}...` : "MISSING");
  console.log("- Key ID:", keyId ? `${keyId.substring(0, 4)}...` : "MISSING");
  console.log("- P8 Certificate:", p8CertificateBase64 ? "PRESENT" : "MISSING");

  if (!teamId || !keyId || !p8CertificateBase64) {
    throw new Error("Missing APNS credentials: APPLE_TEAM_ID, APNS_KEY_ID, or APNS_P8_CERTIFICATE");
  }

  // Decode the base64-encoded P8 certificate
  let p8Certificate: string;
  try {
    p8Certificate = atob(p8CertificateBase64);
    console.log("✅ Successfully decoded base64 certificate");
  } catch (error) {
    throw new Error(`Failed to decode base64 certificate: ${error.message}`);
  }

  // JWT Header
  const header = {
    alg: "ES256",
    kid: keyId,
  };

  // JWT Payload - ensure issued at time is not in the future
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: teamId,
    iat: now,
  };

  console.log("JWT payload:", { iss: teamId, iat: now });

  // Base64 URL encode (without padding)
  const base64UrlEncode = (obj: any) => {
    return btoa(JSON.stringify(obj))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=/g, "");
  };

  const encodedHeader = base64UrlEncode(header);
  const encodedPayload = base64UrlEncode(payload);
  
  // Create the message to sign
  const message = `${encodedHeader}.${encodedPayload}`;
  
  // Parse the P8 certificate to extract the private key
  // Handle both single-line and multi-line certificate formats
  let cleanedCertificate = p8Certificate
    .replace(/\\n/g, '\n')  // Handle escaped newlines
    .replace(/\r\n/g, '\n') // Normalize line endings
    .replace(/\r/g, '\n');  // Handle old Mac line endings
  
  console.log("Certificate first/last lines:", 
    cleanedCertificate.split('\n')[0],
    "...",
    cleanedCertificate.split('\n').slice(-2)[0]
  );
  
  const p8Lines = cleanedCertificate.split('\n');
  const keyData = p8Lines
    .filter(line => !line.includes('-----BEGIN') && !line.includes('-----END'))
    .join('')
    .replace(/\s/g, '');
  
  if (!keyData) {
    throw new Error("Invalid P8 certificate format: no key data found");
  }

  console.log("Extracted key data length:", keyData.length);
  
  try {
    // Import the private key
    const keyBuffer = Uint8Array.from(atob(keyData), c => c.charCodeAt(0));
    
    const privateKey = await crypto.subtle.importKey(
      "pkcs8",
      keyBuffer,
      {
        name: "ECDSA",
        namedCurve: "P-256",
      },
      false,
      ["sign"]
    );

    console.log("✅ Private key imported successfully!");

    // Sign the message
    const encoder = new TextEncoder();
    const data = encoder.encode(message);
    const signature = await crypto.subtle.sign(
      {
        name: "ECDSA",
        hash: "SHA-256",
      },
      privateKey,
      data
    );

    // Convert signature to base64url format
    const signatureArray = new Uint8Array(signature);
    const encodedSignature = btoa(String.fromCharCode(...signatureArray))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=/g, "");

    const jwt = `${message}.${encodedSignature}`;
    console.log("✅ JWT created successfully, length:", jwt.length);
    
    return jwt;
  } catch (error) {
    console.error("❌ Error in JWT creation:", error);
    throw new Error(`Failed to create APNS JWT: ${error.message}`);
  }
}

// Helper function to send APNS notification
async function sendAPNSNotification(deviceToken: string, title: string, body: string, payload?: any): Promise<void> {
  const bundleId = Deno.env.get("APPLE_BUNDLE_ID");
  
  if (!bundleId) {
    throw new Error("Missing APPLE_BUNDLE_ID environment variable");
  }

  console.log("Bundle ID:", bundleId);

  // Create JWT token for authentication
  const jwtToken = await createAPNSJWT();

  // Prepare the notification payload
  const apnsPayload = {
    aps: {
      alert: {
        title,
        body,
      },
      sound: "default",
      badge: 1,
    },
    ...payload, // Include custom payload data
  };

  console.log("APNS payload:", JSON.stringify(apnsPayload, null, 2));

  // APNS endpoint (use production for live app)
  const apnsUrl = `https://api.push.apple.com/3/device/${deviceToken}`;

  console.log("Sending to APNS URL:", apnsUrl);

  const response = await fetch(apnsUrl, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${jwtToken}`,
      "apns-topic": bundleId,
      "apns-push-type": "alert",
      "apns-priority": "10",
      "Content-Type": "application/json",
    },
    body: JSON.stringify(apnsPayload),
  });

  const responseText = await response.text();
  console.log("APNS Response Status:", response.status);
  console.log("APNS Response Headers:", Object.fromEntries(response.headers.entries()));
  console.log("APNS Response Body:", responseText);

  if (!response.ok) {
    // Don't throw error here - we'll handle invalid tokens separately
    console.error(`APNS request failed: ${response.status} ${response.statusText} - ${responseText}`);
    return;
  }

  console.log("APNS notification sent successfully");
}

serve(async (req) => {
  try {
    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Get the request body
    const payload: WebhookPayload = await req.json();

    // Verify this is a session match event
    if (
      payload.table !== 'sessions' || 
      payload.type !== 'UPDATE' || 
      payload.record.status !== 'matched' || 
      payload.old_record.status === 'matched'
    ) {
      return new Response(JSON.stringify({ message: 'Not a match event' }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    const sessionId = payload.record.id;
    const matchedOptionId = payload.record.matched_option_id;

    // Get option details
    const { data: optionData, error: optionError } = await supabaseClient
      .from('options')
      .select('label')
      .eq('id', matchedOptionId)
      .single();

    if (optionError) {
      throw new Error(`Error fetching option: ${optionError.message}`);
    }

    // Get all participants with APNS tokens
    const { data: participants, error: participantsError } = await supabaseClient
      .from('session_participants')
      .select('user_id')
      .eq('session_id', sessionId);

    if (participantsError) {
      throw new Error(`Error fetching participants: ${participantsError.message}`);
    }

    // Extract user IDs
    const userIds = participants.map(p => p.user_id);
    
    // Get users with valid APNS tokens
    const { data: users, error: usersError } = await supabaseClient
      .from('users')
      .select('id, apns_token')
      .in('id', userIds)
      .not('apns_token', 'is', null);
    
    if (usersError) {
      throw new Error(`Error fetching users: ${usersError.message}`);
    }

    // Create notification payload
    const notificationData: NotificationData = {
      title: 'Match Found!',
      body: `Everyone agreed on ${optionData.label}`,
      data: {
        sessionId,
        optionId: matchedOptionId
      }
    };

    console.log(`Sending notifications to ${users.length} users`);

    // Keep track of invalid tokens to update in the database
    const invalidTokens: string[] = [];
    const sentNotifications: number = users.length;
    
    // Send notifications to all users with valid tokens
    const notificationPromises = users.map(async (user) => {
      try {
        await sendAPNSNotification(
          user.apns_token,
          notificationData.title,
          notificationData.body,
          notificationData.data
        );
      } catch (error) {
        console.error(`Error sending notification to user ${user.id}:`, error);
        
        // Check if the error indicates an invalid token
        if (error.message.includes('BadDeviceToken') || error.message.includes('DeviceTokenNotForTopic')) {
          invalidTokens.push(user.id);
        }
      }
    });
    
    // Wait for all notifications to be sent
    await Promise.all(notificationPromises);
    
    // Update any invalid tokens in the database
    if (invalidTokens.length > 0) {
      console.log(`Clearing ${invalidTokens.length} invalid APNS tokens`);
      const { error: updateError } = await supabaseClient
        .from('users')
        .update({ apns_token: null })
        .in('id', invalidTokens);
        
      if (updateError) {
        console.error(`Error clearing invalid tokens:`, updateError);
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `Sent notifications to ${sentNotifications} users, cleared ${invalidTokens.length} invalid tokens`,
        matched_option: optionData.label 
      }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 200 
      }
    );

  } catch (error) {
    console.error('Error processing notification:', error);
    
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});