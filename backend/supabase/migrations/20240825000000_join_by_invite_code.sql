-- Function to join a session by invite code, bypassing RLS entirely
CREATE OR REPLACE FUNCTION join_session_by_invite_code(p_invite_code TEXT, p_user_id UUID)
RETURNS JSONB
SECURITY DEFINER -- This allows the function to bypass RLS
AS $$
DECLARE
  v_session_id UUID;
  v_session_status TEXT;
  v_participant_count INT;
  v_quorum_n INT;
  v_already_joined BOOLEAN;
  v_session_data JSONB;
BEGIN
  -- Find the session with the given invite code
  SELECT 
    id, status, quorum_n INTO v_session_id, v_session_status, v_quorum_n
  FROM sessions
  WHERE invite_code = p_invite_code;
  
  -- Check if session exists
  IF v_session_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'not_found',
      'message', 'No session found with this invite code'
    );
  END IF;
  
  -- Check session status
  IF v_session_status != 'open' THEN
    IF v_session_status = 'matched' THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'session_matched',
        'message', 'This session already has a match'
      );
    ELSE
      RETURN jsonb_build_object(
        'success', false,
        'error', 'session_closed',
        'message', 'This session is closed'
      );
    END IF;
  END IF;
  
  -- Check if user is already a participant
  SELECT EXISTS (
    SELECT 1 FROM session_participants
    WHERE session_id = v_session_id AND user_id = p_user_id
  ) INTO v_already_joined;
  
  IF v_already_joined THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'already_joined',
      'message', 'You have already joined this session'
    );
  END IF;
  
  -- Check if session is full (participant count >= quorum)
  SELECT COUNT(*) INTO v_participant_count
  FROM session_participants
  WHERE session_id = v_session_id;
  
  IF v_participant_count >= v_quorum_n THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'session_full',
      'message', 'This session is full'
    );
  END IF;
  
  -- Join the session (add participant)
  INSERT INTO session_participants (session_id, user_id)
  VALUES (v_session_id, p_user_id);
  
  -- Get full session details to return
  SELECT 
    jsonb_build_object(
      'success', true,
      'session', jsonb_build_object(
        'id', s.id,
        'status', s.status,
        'creator_id', s.creator_id,
        'category_id', s.category_id,
        'quorum_n', s.quorum_n,
        'matched_option_id', s.matched_option_id,
        'invite_code', s.invite_code,
        'created_at', s.created_at,
        'category', (
          SELECT jsonb_build_object(
            'id', c.id,
            'name', c.name,
            'icon_url', c.icon_url
          )
          FROM categories c
          WHERE c.id = s.category_id
        )
      )
    )
  INTO v_session_data
  FROM sessions s
  WHERE s.id = v_session_id;
  
  RETURN v_session_data;
END;
$$ LANGUAGE plpgsql;