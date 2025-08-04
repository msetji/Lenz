import React, { useEffect, useState, useRef, useCallback } from 'react';
import { View, Text, FlatList, Dimensions, ActivityIndicator, RefreshControl } from 'react-native';
import { useAuth } from '@/contexts/AuthContext';
import { useLocation } from '@/contexts/LocationContext';
import { supabase } from '@/lib/supabase';
import VideoPlayer from '@/components/VideoPlayer';
import { Database } from '@/types/database';
import { Ionicons } from '@expo/vector-icons';

type Video = Database['public']['Functions']['get_nearby_videos']['Returns'][0];

const { height } = Dimensions.get('window');

export default function HomeScreen() {
  const { user } = useAuth();
  const { location } = useLocation();
  const [videos, setVideos] = useState<Video[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);
  const flatListRef = useRef<FlatList>(null);

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

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await fetchNearbyVideos();
    setRefreshing(false);
  }, [location]);

  const onViewableItemsChanged = useRef(({ viewableItems }: any) => {
    if (viewableItems.length > 0) {
      setCurrentIndex(viewableItems[0].index || 0);
    }
  }).current;

  const viewabilityConfig = useRef({
    itemVisiblePercentThreshold: 50,
  }).current;

  const renderVideo = ({ item, index }: { item: Video; index: number }) => (
    <View style={{ height }}>
      <VideoPlayer 
        video={item} 
        isActive={index === currentIndex}
      />
    </View>
  );

  const getItemLayout = (data: any, index: number) => ({
    length: height,
    offset: height * index,
    index,
  });

  if (loading) {
    return (
      <View className="flex-1 bg-background justify-center items-center">
        <ActivityIndicator size="large" color="#0A84FF" />
        <Text className="text-text-secondary mt-4">Loading nearby videos...</Text>
      </View>
    );
  }

  if (videos.length === 0 && !loading) {
    return (
      <View className="flex-1 bg-black justify-center items-center px-6">
        <Ionicons name="videocam-outline" size={80} color="#8E8E93" />
        <Text className="text-white text-2xl font-bold text-center mt-6 mb-4">
          No videos nearby
        </Text>
        <Text className="text-gray-400 text-center text-lg leading-6">
          Be the first to share a video in your area!
        </Text>
        <Text className="text-gray-500 text-center text-sm mt-4">
          Pull down to refresh and check for new content
        </Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-black">
      <FlatList
        ref={flatListRef}
        data={videos}
        renderItem={renderVideo}
        keyExtractor={(item) => item.id.toString()}
        pagingEnabled
        showsVerticalScrollIndicator={false}
        snapToInterval={height}
        snapToAlignment="start"
        decelerationRate="fast"
        onViewableItemsChanged={onViewableItemsChanged}
        viewabilityConfig={viewabilityConfig}
        getItemLayout={getItemLayout}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor="#FFFFFF"
            colors={['#0A84FF']}
          />
        }
        removeClippedSubviews
        maxToRenderPerBatch={3}
        windowSize={5}
        initialNumToRender={2}
      />
    </View>
  );
} 