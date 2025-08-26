# Implementing Session Joining with Invite Codes

This document explains how to implement the session joining functionality that bypasses Row Level Security (RLS) constraints in Supabase.

## The Problem

In our application, RLS policies restrict users to only see sessions they've created or are already participating in. However, when a user wants to join a session using an invite code, they need to first see the session details before becoming a participant - creating a circular dependency.

## The Solution

We use a Postgres function with `SECURITY DEFINER` to bypass RLS policies for the complete join-by-invite process. This function:

1. Finds a session by its invite code
2. Validates the session status (open, not matched, not full)
3. Checks if the user is already a participant
4. Adds the user as a participant if all checks pass
5. Returns the complete session data

## Implementation Steps

### 1. Apply the SQL Migration

The migration file `20240825000000_join_by_invite_code.sql` contains the function definition:

```sql
CREATE OR REPLACE FUNCTION join_session_by_invite_code(p_invite_code TEXT, p_user_id UUID)
RETURNS JSONB
SECURITY DEFINER -- This bypasses RLS
AS $$ ... $$
```

Apply this migration to your Supabase instance using either:

- The Supabase dashboard's SQL Editor
- The Supabase CLI migration command
- Your CI/CD deployment pipeline

### 2. Testing the Function

You can test the function in the Supabase SQL Editor:

```sql
SELECT join_session_by_invite_code('ABCD123', '00000000-0000-0000-0000-000000000000');
```

It should return an appropriate response indicating success or the specific error.

## How It Works

The function performs several steps:

1. **Session Lookup**: Finds the session with the provided invite code
2. **Validation Checks**:
   - Verifies the session exists
   - Confirms the session is still open
   - Checks if the user is already a participant
   - Ensures the session isn't already full
3. **Participant Addition**: Adds the user as a participant if all checks pass
4. **Response Formation**: Returns a structured JSON response with:
   - Success/error status
   - Detailed error message if applicable
   - Complete session details on success

## Security Considerations

- The `SECURITY DEFINER` attribute means this function runs with database owner privileges
- The function carefully validates all inputs and conditions before any write operations
- It only performs the specific operation needed (finding and joining a session)
- It enforces the same business rules as the application (session open, not full, etc.)

## Error Handling

The function provides detailed error responses:

- `not_found`: Invalid invite code
- `session_matched`: Session already has a match
- `session_closed`: Session has been closed
- `already_joined`: User has already joined this session
- `session_full`: Session has reached its participant limit

## Client Integration

The iOS app calls this function through Supabase's RPC mechanism, handling the response and appropriate errors.