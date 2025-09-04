-- Migration: Fix storage bucket privacy and policies
-- This migration updates the existing option-images bucket to be private
-- and ensures proper authenticated access policies

DO $$
BEGIN
  -- Update existing bucket to be private
  UPDATE storage.buckets 
  SET public = false 
  WHERE id = 'option-images';
  
  RAISE NOTICE 'Updated option-images bucket to private';
  
END $$;

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Public read access for authenticated users" ON storage.objects;

-- Create new authenticated read access policy
CREATE POLICY "Authenticated read access for option images" ON storage.objects
FOR SELECT USING (bucket_id = 'option-images' AND auth.role() = 'authenticated');

RAISE NOTICE 'Created authenticated read access policy for option-images bucket';
