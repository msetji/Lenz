-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- users table
CREATE TABLE public.users (
  id uuid PRIMARY KEY DEFAULT auth.uid(),
  username text UNIQUE NOT NULL,
  bio text,
  profile_pic_url text,
  created_at timestamptz DEFAULT now()
);

-- videos table
CREATE TABLE public.videos (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  video_url text NOT NULL,
  caption text,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create spatial index for videos
CREATE INDEX videos_lat_lon_idx ON public.videos USING gist (point(latitude, longitude));

-- likes table
CREATE TABLE public.likes (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  video_id bigint REFERENCES public.videos(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE (user_id, video_id)
);

-- comments table
CREATE TABLE public.comments (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  video_id bigint REFERENCES public.videos(id) ON DELETE CASCADE,
  text text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- followers table
CREATE TABLE public.followers (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  follower_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  following_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE (follower_id, following_id)
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.followers ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Users can view all profiles" ON public.users
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for videos
CREATE POLICY "Videos are viewable by everyone" ON public.videos
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own videos" ON public.videos
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own videos" ON public.videos
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own videos" ON public.videos
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for likes
CREATE POLICY "Likes are viewable by everyone" ON public.likes
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own likes" ON public.likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own likes" ON public.likes
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for comments
CREATE POLICY "Comments are viewable by everyone" ON public.comments
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own comments" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON public.comments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for followers
CREATE POLICY "Followers are viewable by everyone" ON public.followers
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own follows" ON public.followers
  FOR INSERT WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can delete own follows" ON public.followers
  FOR DELETE USING (auth.uid() = follower_id);

-- Edge Function: get_nearby_videos
-- This function returns videos ordered by distance ASC, then created_at DESC
CREATE OR REPLACE FUNCTION get_nearby_videos(
  user_latitude double precision,
  user_longitude double precision,
  radius_km double precision DEFAULT 20
)
RETURNS TABLE (
  id bigint,
  user_id uuid,
  video_url text,
  caption text,
  latitude double precision,
  longitude double precision,
  created_at timestamptz,
  distance double precision
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    v.id,
    v.user_id,
    v.video_url,
    v.caption,
    v.latitude,
    v.longitude,
    v.created_at,
    (
      6371 * acos(
        cos(radians(user_latitude)) * 
        cos(radians(v.latitude)) * 
        cos(radians(v.longitude) - radians(user_longitude)) + 
        sin(radians(user_latitude)) * 
        sin(radians(v.latitude))
      )
    ) AS distance
  FROM public.videos v
  WHERE (
    6371 * acos(
      cos(radians(user_latitude)) * 
      cos(radians(v.latitude)) * 
      cos(radians(v.longitude) - radians(user_longitude)) + 
      sin(radians(user_latitude)) * 
      sin(radians(v.latitude))
    )
  ) <= radius_km
  ORDER BY distance ASC, v.created_at DESC;
END;
$$;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_nearby_videos TO anon, authenticated; 