export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          username: string
          bio: string | null
          profile_pic_url: string | null
          created_at: string
        }
        Insert: {
          id?: string
          username: string
          bio?: string | null
          profile_pic_url?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          username?: string
          bio?: string | null
          profile_pic_url?: string | null
          created_at?: string
        }
      }
      videos: {
        Row: {
          id: number
          user_id: string
          video_url: string
          caption: string | null
          latitude: number
          longitude: number
          created_at: string
        }
        Insert: {
          id?: number
          user_id: string
          video_url: string
          caption?: string | null
          latitude: number
          longitude: number
          created_at?: string
        }
        Update: {
          id?: number
          user_id?: string
          video_url?: string
          caption?: string | null
          latitude?: number
          longitude?: number
          created_at?: string
        }
      }
      likes: {
        Row: {
          id: number
          user_id: string
          video_id: number
          created_at: string
        }
        Insert: {
          id?: number
          user_id: string
          video_id: number
          created_at?: string
        }
        Update: {
          id?: number
          user_id?: string
          video_id?: number
          created_at?: string
        }
      }
      comments: {
        Row: {
          id: number
          user_id: string
          video_id: number
          text: string
          created_at: string
        }
        Insert: {
          id?: number
          user_id: string
          video_id: number
          text: string
          created_at?: string
        }
        Update: {
          id?: number
          user_id?: string
          video_id?: number
          text?: string
          created_at?: string
        }
      }
      followers: {
        Row: {
          id: number
          follower_id: string
          following_id: string
          created_at: string
        }
        Insert: {
          id?: number
          follower_id: string
          following_id: string
          created_at?: string
        }
        Update: {
          id?: number
          follower_id?: string
          following_id?: string
          created_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      get_nearby_videos: {
        Args: {
          user_latitude: number
          user_longitude: number
          radius_km?: number
        }
        Returns: {
          id: number
          user_id: string
          video_url: string
          caption: string | null
          latitude: number
          longitude: number
          created_at: string
          distance: number
        }[]
      }
    }
    Enums: {
      [_ in never]: never
    }
  }
} 