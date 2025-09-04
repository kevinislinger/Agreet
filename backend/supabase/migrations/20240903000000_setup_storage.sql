-- Migration: Setup Supabase Storage for option images and update schema
-- This migration creates the option-images storage bucket, configures access policies,
-- and updates the options table to use image_path instead of image_url
-- It is idempotent and can be run multiple times safely

DO $$
BEGIN
  -- Create bucket if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'option-images') THEN
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES ('option-images', 'option-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']);
    
    RAISE NOTICE 'Created option-images storage bucket';
  ELSE
    RAISE NOTICE 'Storage bucket option-images already exists';
  END IF;
  
  -- Create policy for public read access if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'objects' 
    AND policyname = 'Public read access for authenticated users'
    AND schemaname = 'storage'
  ) THEN
    CREATE POLICY "Public read access for authenticated users" ON storage.objects
    FOR SELECT USING (bucket_id = 'option-images' AND auth.role() = 'authenticated');
    
    RAISE NOTICE 'Created public read access policy';
  ELSE
    RAISE NOTICE 'Public read access policy already exists';
  END IF;
  
  -- Create policy for file size and type restrictions if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'objects' 
    AND policyname = 'File size and type restrictions'
    AND schemaname = 'storage'
  ) THEN
    CREATE POLICY "File size and type restrictions" ON storage.objects
    FOR INSERT WITH CHECK (
      bucket_id = 'option-images' 
      AND octet_length(file) <= 5242880 
      AND (file_type() IN ('image/jpeg', 'image/png', 'image/webp'))
    );
    
    RAISE NOTICE 'Created file restrictions policy';
  ELSE
    RAISE NOTICE 'File restrictions policy already exists';
  END IF;
  
END $$;

-- Update database schema: change image_url to image_path in options table
DO $$
BEGIN
  -- Check if the column image_url exists and image_path doesn't exist
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'options' 
    AND column_name = 'image_url'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'options' 
    AND column_name = 'image_path'
  ) THEN
    -- Rename the column from image_url to image_path
    ALTER TABLE options RENAME COLUMN image_url TO image_path;
    RAISE NOTICE 'Renamed column image_url to image_path in options table';
  ELSE
    RAISE NOTICE 'Column image_path already exists or image_url does not exist';
  END IF;
  
  -- Update any existing data to use storage paths instead of URLs
  -- This assumes existing URLs can be converted to storage paths
  -- You may want to customize this logic based on your existing data
  UPDATE options 
  SET image_path = REPLACE(image_path, 'https://example.com/images/', '')
  WHERE image_path LIKE 'https://%';
  
  RAISE NOTICE 'Updated existing image paths to use storage format';
  
END $$;
