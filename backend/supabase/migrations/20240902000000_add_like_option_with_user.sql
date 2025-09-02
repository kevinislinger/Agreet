-- Migration: Replace like_option function for edge functions
-- This function allows edge functions to pass the user ID explicitly instead of relying on auth.uid()

-- Function to like an option with explicit user ID (for edge functions)
CREATE OR REPLACE FUNCTION like_option(
  p_session_id UUID,
  p_option_id UUID,
  p_user_id UUID
) RETURNS JSON AS $$
DECLARE
  v_session_status session_status;
  v_matched_option_id UUID;
  v_match_found BOOLEAN := false;
BEGIN
  -- Check if session is open
  SELECT status, matched_option_id INTO v_session_status, v_matched_option_id
  FROM sessions
  WHERE id = p_session_id;
  
  IF v_session_status != 'open' THEN
    RETURN json_build_object(
      'success', false,
      'match_found', true,
      'matched_option_id', v_matched_option_id,
      'message', 'Session is already ' || v_session_status::text
    );
  END IF;
  
  -- Insert like with explicit user ID
  BEGIN
    INSERT INTO likes (
      session_id,
      option_id,
      user_id
    ) VALUES (
      p_session_id,
      p_option_id,
      p_user_id
    );
  EXCEPTION WHEN unique_violation THEN
    -- Like already exists, ignore
    NULL;
  END;
  
  -- Check if session status changed to matched after our like
  -- This happens via the trigger we created
  SELECT status = 'matched', matched_option_id INTO v_match_found, v_matched_option_id
  FROM sessions
  WHERE id = p_session_id;
  
  RETURN json_build_object(
    'success', true,
    'match_found', v_match_found,
    'matched_option_id', v_matched_option_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
