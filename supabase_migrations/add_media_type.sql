-- Add support for photos in addition to videos
-- Add media_type column and media_urls array for slideshow support

-- Add media_type column (default to 'video' for existing records)
ALTER TABLE videos ADD COLUMN IF NOT EXISTS media_type TEXT DEFAULT 'video';

-- Add media_urls array column for slideshow photos
ALTER TABLE videos ADD COLUMN IF NOT EXISTS media_urls TEXT[] DEFAULT '{}';

-- Update constraint to allow either video_url OR media_urls
-- For slideshows (photos), media_urls will be populated
-- For videos, video_url will be populated
