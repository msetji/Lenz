-- Enable RLS on videos table (if not already enabled)
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;

-- Drop existing insert policy if it exists
DROP POLICY IF EXISTS "Users can insert their own videos" ON videos;

-- Create policy to allow authenticated users to insert their own videos/photos
CREATE POLICY "Users can insert their own videos"
ON videos
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id::uuid);

-- Also allow users to select all videos (for feed)
DROP POLICY IF EXISTS "Public videos are viewable by everyone" ON videos;
CREATE POLICY "Public videos are viewable by everyone"
ON videos
FOR SELECT
TO authenticated
USING (true);

-- Allow users to update their own videos
DROP POLICY IF EXISTS "Users can update their own videos" ON videos;
CREATE POLICY "Users can update their own videos"
ON videos
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id::uuid)
WITH CHECK (auth.uid() = user_id::uuid);

-- Allow users to delete their own videos
DROP POLICY IF EXISTS "Users can delete their own videos" ON videos;
CREATE POLICY "Users can delete their own videos"
ON videos
FOR DELETE
TO authenticated
USING (auth.uid() = user_id::uuid);
