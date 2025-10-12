# Photo Slideshow Implementation Guide

## Overview
Add support for uploading multiple photos in a slideshow format alongside videos.

## Database Changes

### 1. Run this SQL in Supabase:
```sql
-- Add media_type column (default to 'video' for existing records)
ALTER TABLE videos ADD COLUMN IF NOT EXISTS media_type TEXT DEFAULT 'video';

-- Add media_urls array column for slideshow photos
ALTER TABLE videos ADD COLUMN IF NOT EXISTS media_urls TEXT[] DEFAULT '{}';

-- Make video_url nullable since photos won't have it
ALTER TABLE videos ALTER COLUMN video_url DROP NOT NULL;
```

## Code Changes Completed

✅ **Video Model Updated** (`/Users/msetji/Projects/Lenz/Lenz/Models/Video.swift`)
- Added `MediaType` enum (video/photo)
- Added `mediaUrls` array for slideshow
- Made `videoURL` optional
- Added `primaryMediaURL` computed property

✅ **New Upload View Created** (`UploadViewNew.swift`)
- Segmented picker to choose between Video/Photos
- Support for up to 10 photos
- Slideshow preview with TabView
- Separate upload flows

## Next Steps (To Complete)

### 2. Create UploadViewModelNew
Create `/Users/msetji/Projects/Lenz/Lenz/Features/Upload/UploadViewModelNew.swift` with:
- `selectedPhotoItems: [PhotosPickerItem]`
- `selectedPhotos: [UIImage]`
- `loadPhotos()` method
- `uploadPhotos()` method that uploads to Supabase Storage

### 3. Update MainTabView
Replace `UploadView()` with `UploadViewNew()` in the sheet

### 4. Update FeedView/VideoPlayerView
Add slideshow support:
- Check `video.mediaType`
- If `.photo`, show TabView with `video.mediaUrls`
- If `.video`, show existing video player

### 5. Update ProfileView
Update VideoThumbnail to show photo icon for photo posts

## Usage
1. User taps Upload tab
2. Chooses "Photos" or "Video" via segmented control
3. For photos: selects 1-10 images
4. Images preview in slideshow
5. Tap "Upload Photos" to upload
6. Photos stored in Supabase Storage `videos` bucket
7. Record created with `media_type='photo'` and `media_urls` array

## Benefits
- Users can share photo memories from locations
- Slideshow format (like Instagram carousel)
- Maintains location-based discovery
- Reuses existing like/comment/feed infrastructure
