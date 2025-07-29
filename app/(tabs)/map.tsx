import React, { useEffect, useState } from 'react';
import { View, Text, TouchableOpacity, ActivityIndicator } from 'react-native';
import { useLocation } from '@/contexts/LocationContext';
import { supabase } from '@/lib/supabase';
import { Database } from '@/types/database';
import MapView, { Marker } from 'react-native-maps';
import { Ionicons } from '@expo/vector-icons';

type Video = Database['public']['Functions']['get_nearby_videos']['Returns'][0];

export default function MapScreen() {
  const { location } = useLocation();
  const [videos, setVideos] = useState<Video[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);

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
        radius_km: 50, // Larger radius for map view
      });

      if (error) throw error;
      setVideos(data || []);
    } catch (error) {
      console.error('Error fetching nearby videos:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View className="flex-1 bg-background justify-center items-center">
        <ActivityIndicator size="large" color="#0A84FF" />
        <Text className="text-text-secondary mt-4">Loading map...</Text>
      </View>
    );
  }

  if (!location) {
    return (
      <View className="flex-1 bg-background justify-center items-center px-6">
        <Ionicons name="location-outline" size={64} color="#8E8E93" />
        <Text className="text-text text-xl font-semibold text-center mt-4 mb-2">
          Location Required
        </Text>
        <Text className="text-text-secondary text-center">
          Enable location access to see videos on the map
        </Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-background">
      <MapView
        style={{ flex: 1 }}
        initialRegion={{
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
          latitudeDelta: 0.01,
          longitudeDelta: 0.01,
        }}
        showsUserLocation
        showsMyLocationButton
      >
        {/* User location marker */}
        <Marker
          coordinate={{
            latitude: location.coords.latitude,
            longitude: location.coords.longitude,
          }}
          title="You are here"
          pinColor="#0A84FF"
        />

        {/* Video markers */}
        {videos.map((video) => (
          <Marker
            key={video.id}
            coordinate={{
              latitude: video.latitude,
              longitude: video.longitude,
            }}
            onPress={() => setSelectedVideo(video)}
          >
            <View className="bg-primary rounded-full p-2">
              <Ionicons name="videocam" size={16} color="#FFFFFF" />
            </View>
          </Marker>
        ))}
      </MapView>

      {/* Selected video info */}
      {selectedVideo && (
        <View className="absolute bottom-4 left-4 right-4 bg-surface rounded-lg p-4 border border-border">
          <View className="flex-row items-center justify-between mb-2">
            <Text className="text-text font-semibold">
              @{selectedVideo.user_id}
            </Text>
            <TouchableOpacity
              onPress={() => setSelectedVideo(null)}
              className="p-1"
            >
              <Ionicons name="close" size={20} color="#8E8E93" />
            </TouchableOpacity>
          </View>
          
          {selectedVideo.caption && (
            <Text className="text-text-secondary mb-2" numberOfLines={2}>
              {selectedVideo.caption}
            </Text>
          )}
          
          <Text className="text-text-secondary text-sm">
            {selectedVideo.distance < 1 
              ? `${Math.round(selectedVideo.distance * 1000)}m away`
              : `${selectedVideo.distance.toFixed(1)}km away`
            }
          </Text>
          
          <TouchableOpacity className="bg-primary rounded-lg py-2 mt-3">
            <Text className="text-text text-center font-semibold">
              Watch Video
            </Text>
          </TouchableOpacity>
        </View>
      )}

      {/* Refresh button */}
      <TouchableOpacity
        onPress={fetchNearbyVideos}
        className="absolute top-12 right-4 bg-surface rounded-full p-3 border border-border"
      >
        <Ionicons name="refresh" size={24} color="#0A84FF" />
      </TouchableOpacity>
    </View>
  );
} 