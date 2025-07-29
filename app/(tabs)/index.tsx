import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, Dimensions, ActivityIndicator } from 'react-native';
import { useAuth } from '@/contexts/AuthContext';
import { useLocation } from '@/contexts/LocationContext';
import { supabase } from '@/lib/supabase';
import VideoPlayer from '@/components/VideoPlayer';
import { Database } from '@/types/database';

type Video = Database['public']['Functions']['get_nearby_videos']['Returns'][0];

const { height } = Dimensions.get('window');

export default function HomeScreen() {
  const { user } = useAuth();
  const { location } = useLocation();
  const [videos, setVideos] = useState<Video[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    if (location) {
      fetchNearbyVideos();
    }
  }, [location]);

  const fetchNearbyVideos = async () => {
    if (!location) return;

    try {
      setLoading(true);
      const { data, error } = await supabase.rpc('get_nearby_videos', {
        user_latitude: location.coords.latitude,
        user_longitude: location.coords.longitude,
        radius_km: 20,
      });

      if (error) throw error;
      setVideos(data || []);
    } catch (error) {
      console.error('Error fetching nearby videos:', error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchNearbyVideos();
    setRefreshing(false);
  };

  const renderVideo = ({ item }: { item: Video }) => (
    <View style={{ height }}>
      <VideoPlayer video={item} />
    </View>
  );

  if (loading) {
    return (
      <View className="flex-1 bg-background justify-center items-center">
        <ActivityIndicator size="large" color="#0A84FF" />
        <Text className="text-text-secondary mt-4">Loading nearby videos...</Text>
      </View>
    );
  }

  if (videos.length === 0) {
    return (
      <View className="flex-1 bg-background justify-center items-center px-6">
        <Text className="text-text text-xl font-semibold text-center mb-2">
          No videos nearby
        </Text>
        <Text className="text-text-secondary text-center">
          Be the first to share a video in your area!
        </Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-background">
      <FlatList
        data={videos}
        renderItem={renderVideo}
        keyExtractor={(item) => item.id.toString()}
        pagingEnabled
        showsVerticalScrollIndicator={false}
        snapToInterval={height}
        snapToAlignment="start"
        decelerationRate="fast"
        onRefresh={onRefresh}
        refreshing={refreshing}
      />
    </View>
  );
} 