// Edge Function to handle option likes
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Define types
interface LikeRequest {
  session_id: string;
  option_id: string;
}

serve(async (req) => {
  try {
    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
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
    
    // Verify the user is authenticated
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(jwt);
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid authentication token' }),
        { headers: { 'Content-Type': 'application/json' }, status: 401 }
      );
    }

    // Get the request body
    const { session_id, option_id }: LikeRequest = await req.json();

    // Validate required parameters
    if (!session_id || !option_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters: session_id and option_id are required' }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    // Call the like_option RPC function with the authenticated user context
    const { data, error } = await supabaseClient.rpc('like_option', {
      p_session_id: session_id,
      p_option_id: option_id,
    }, {
      headers: {
        Authorization: `Bearer ${jwt}`
      }
    });

    if (error) {
      console.error('RPC error:', error);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Error processing like: ${error.message}` 
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    return new Response(
      JSON.stringify(data),
      { headers: { 'Content-Type': 'application/json' }, status: 200 }
    );

  } catch (error) {
    console.error('Error processing like:', error);
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Internal server error' 
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
