# Supabase Database Setup for Lenz

This folder contains SQL scripts for your Supabase database.

## Files

- **`migration_update.sql`** - Main migration script (already run ✅)
- **`verify_setup.sql`** - Verification script to check your setup
- **`README.md`** - This file

## Verify Your Setup

To verify everything is set up correctly:

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project (vlnjufgnjoluvuzfzhju)
3. Navigate to **SQL Editor**
4. Click **New Query**
5. Copy and paste the contents of `verify_setup.sql`
6. Click **Run**

This will show you:
- All tables and columns
- Foreign key relationships
- Indexes
- Triggers
- Functions
- RLS policies
- Row counts
- Storage buckets

Copy the results and share them to verify everything looks correct.

## Storage Buckets

### Create Storage Bucket for Profile Pictures

1. Navigate to **Storage** in your Supabase Dashboard
2. Click **Create a new bucket**
3. Name it `profiles`
4. Make it **Public** (so profile pictures are accessible)
5. Click **Create bucket**

#### Set Storage Policies

1. Click on the `profiles` bucket
2. Go to **Policies** tab
3. Click **New Policy** for INSERT:
   - Policy Name: "Users can upload their own profile pictures"
   - Target Roles: `authenticated`
   - Check: `(bucket_id = 'profiles'::text)`
4. Click **New Policy** for SELECT:
   - Policy Name: "Anyone can view profile pictures"
   - Target Roles: `public`
   - Check: `(bucket_id = 'profiles'::text)`

### 4. Optional: Create Storage Bucket for Videos

1. Navigate to **Storage** in your Supabase Dashboard
2. Click **Create a new bucket**
3. Name it `videos`
4. Make it **Public**
5. Set up similar policies as the profiles bucket

## Database Schema Overview

### Users Table
- Extends Supabase Auth users
- Fields: `id`, `email`, `username`, `avatar_url`, `created_at`
- Username is unique and optional (for profile setup flow)

### Videos Table
- Stores video metadata
- Fields: `id`, `user_id`, `video_url`, `thumbnail_url`, `caption`, location data, counts, `created_at`
- Automatically maintains like and comment counts via triggers

### Likes Table
- Many-to-many relationship between users and videos
- Unique constraint prevents duplicate likes

### Comments Table
- User comments on videos
- References both users and videos

## Testing the Setup

After running the migrations, you can test:

1. Sign in with Google OAuth
2. A user record should be automatically created in the `users` table
3. Complete your profile setup (username + profile picture)
4. The profile picture should upload to the `profiles` bucket

## Troubleshooting

### User creation fails
- Check if the trigger was created successfully
- Verify RLS policies allow inserts
- Check the Supabase logs for errors

### Profile picture upload fails
- Ensure the `profiles` bucket exists and is public
- Verify storage policies are set correctly
- Check file size limits (default is 50MB)

### Can't fetch user data
- Verify RLS policies are enabled and correct
- Check that the user ID matches between `auth.users` and `public.users`
