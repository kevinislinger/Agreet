-- This migration removes the session_options table and related functionality
-- Migration timestamp: 2024-08-26 00:00:00
-- Reason: Session options order should be randomized on client side, not stored in database

-- Drop the session_options table and all related objects
DROP TABLE IF EXISTS session_options CASCADE;

-- Update the create_session function to remove session_options creation
CREATE OR REPLACE FUNCTION create_session(
  p_category_id UUID,
  p_quorum_n INTEGER DEFAULT 2
) RETURNS JSON AS $$
DECLARE
  v_session_id UUID;
  v_invite_code TEXT;
  v_session_record sessions%ROWTYPE;
BEGIN
  -- Generate a random 6-character invite code
  v_invite_code := upper(substr(md5(random()::text), 1, 6));
  
  -- Create the session
  INSERT INTO sessions (
    creator_id,
    category_id,
    quorum_n,
    invite_code
  ) VALUES (
    auth.uid(),
    p_category_id,
    p_quorum_n,
    v_invite_code
  ) RETURNING id INTO v_session_id;
  
  -- Add the creator as a participant
  INSERT INTO session_participants (
    session_id,
    user_id
  ) VALUES (
    v_session_id,
    auth.uid()
  );
  
  -- Get the created session
  SELECT * INTO v_session_record FROM sessions WHERE id = v_session_id;
  
  -- Return session details as JSON
  RETURN json_build_object(
    'session_id', v_session_id,
    'invite_code', v_invite_code,
    'created_at', v_session_record.created_at
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the join_session function to remove any session_options references
-- (This function doesn't actually reference session_options, but keeping for completeness)
CREATE OR REPLACE FUNCTION join_session(
  p_invite_code TEXT
) RETURNS JSON AS $$
DECLARE
  v_session_id UUID;
  v_session_status session_status;
  v_matched_option_id UUID;
BEGIN
  -- Find the session
  SELECT id, status, matched_option_id 
  INTO v_session_id, v_session_status, v_matched_option_id
  FROM sessions
  WHERE invite_code = upper(p_invite_code);
  
  -- Check if session exists
  IF v_session_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'message', 'Session not found'
    );
  END IF;
  
  -- Check if session is still open
  IF v_session_status != 'open' THEN
    RETURN json_build_object(
      'success', false,
      'message', 'Session is ' || v_session_status::text,
      'session_id', v_session_id,
      'matched_option_id', v_matched_option_id
    );
  END IF;
  
  -- Try to join the session
  BEGIN
    INSERT INTO session_participants (
      session_id,
      user_id
    ) VALUES (
      v_session_id,
      auth.uid()
    );
    
    RETURN json_build_object(
      'success', true,
      'session_id', v_session_id
    );
  EXCEPTION WHEN OTHERS THEN
    -- Handle errors (like session full, already joined, etc)
    RETURN json_build_object(
      'success', false,
      'message', SQLERRM
    );
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
