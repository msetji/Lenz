import React, { useEffect, useState } from 'react';
import { View, Text, ActivityIndicator, Alert } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/lib/supabase';
import { Database } from '@/types/database';
import VideoPlayer from '@/components/VideoPlayer';

type VideoData = Database['public']['Functions']['get_nearby_videos']['Returns'][0];

export default function VideoDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { user } = useAuth();
  const router = useRouter();
  const [video, setVideo] = useState<VideoData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) {
      router.push('/auth');
      return;
    }

    fetchVideo();
  }, [id, user]);

  const fetchVideo = async () => {
    if (!id) return;

    try {
      const { data, error } = await supabase
        .from('videos')
        .select(`
          id,
          user_id,
          video_url,
          caption,
          latitude,
          longitude,
          created_at
        `)
        .eq('id', id)
        .single();

      if (error) throw error;

      if (data) {
        setVideo({
          ...data,
          distance: 0, // Distance calculation would require current location
        });
      }
    } catch (error) {
      console.error('Error fetching video:', error);
      Alert.alert('Error', 'Failed to load video');
      router.replace('/(tabs)');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View className="flex-1 bg-background justify-center items-center">
        <ActivityIndicator size="large" color="#0A84FF" />
      </View>
    );
  }

  if (!video) {
    return (
      <View className="flex-1 bg-background justify-center items-center">
        <Text className="text-text text-lg">Video not found</Text>
      </View>
    );
  }

  return <VideoPlayer video={video} />;
}