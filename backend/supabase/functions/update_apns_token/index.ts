// Edge Function to update the APNS token for a user
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Define types
interface UpdateTokenRequest {
  token: string | null;  // null to remove token
}

serve(async (req) => {
  try {
    // Create Supabase client with service role key for admin access
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Get the authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Missing or invalid authorization header' }),
        { headers: { 'Content-Type': 'application/json' }, status: 401 }
      );
    }

    // Extract the JWT token
    const jwt = authHeader.replace('Bearer ', '');
    
    // Verify the user is authenticated and get user info
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(jwt);
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid authentication token' }),
        { headers: { 'Content-Type': 'application/json' }, status: 401 }
      );
    }

    // Get the request body
    const { token }: UpdateTokenRequest = await req.json();

    // Call the update_apns_token RPC function with the authenticated user context
    const { data, error } = await supabaseClient.rpc('update_apns_token', {
      p_token: token,
    });

    if (error) {
      console.error('RPC error:', error);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Error updating token: ${error.message}` 
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 }
    );

  } catch (error) {
    console.error('Error updating token:', error);
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Internal server error' 
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
