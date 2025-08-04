import React, { useEffect, useState, useMemo } from 'react';
import { View, Text, TouchableOpacity, ActivityIndicator, Image } from 'react-native';
import { useLocation } from '@/contexts/LocationContext';
import { supabase } from '@/lib/supabase';
import { Database } from '@/types/database';
import MapView, { Marker, Callout } from 'react-native-maps';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

type Video = Database['public']['Functions']['get_nearby_videos']['Returns'][0];

interface VideoCluster {
  id: string;
  latitude: number;
  longitude: number;
  videos: Video[];
  count: number;
}

export default function MapScreen() {
  const { location } = useLocation();
  const router = useRouter();
  const [videos, setVideos] = useState<Video[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);
  const [mapRegion, setMapRegion] = useState({
    latitude: 37.78825,
    longitude: -122.4324,
    latitudeDelta: 0.01,
    longitudeDelta: 0.01,
  });

  useEffect(() => {
    if (location) {
      setMapRegion({
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        latitudeDelta: 0.01,
        longitudeDelta: 0.01,
      });
      fetchNearbyVideos();
    }
  }, [location]);

  // Simple clustering algorithm
  const clusterVideos = useMemo(() => {
    const clusters: VideoCluster[] = [];
    const processedVideos = new Set<number>();

    videos.forEach((video) => {
      if (processedVideos.has(video.id)) return;

      const nearbyVideos = videos.filter((otherVideo) => {
        if (processedVideos.has(otherVideo.id) || video.id === otherVideo.id) return false;
        
        // Calculate distance between videos (rough approximation)
        const latDiff = Math.abs(video.latitude - otherVideo.latitude);
        const lonDiff = Math.abs(video.longitude - otherVideo.longitude);
        const distance = Math.sqrt(latDiff * latDiff + lonDiff * lonDiff);
        
        return distance < 0.001; // ~100m clustering radius
      });

      const clusterVideos = [video, ...nearbyVideos];
      
      clusterVideos.forEach(v => processedVideos.add(v.id));

      clusters.push({
        id: `cluster-${video.id}`,
        latitude: video.latitude,
        longitude: video.longitude,
        videos: clusterVideos,
        count: clusterVideos.length,
      });
    });

    return clusters;
  }, [videos]);

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

  const renderClusterMarker = (cluster: VideoCluster) => (
    <Marker
      key={cluster.id}
      coordinate={{
        latitude: cluster.latitude,
        longitude: cluster.longitude,
      }}
      onPress={() => {
        if (cluster.count === 1) {
          setSelectedVideo(cluster.videos[0]);
        } else {
          // Handle cluster tap - could expand or show list
          setSelectedVideo(cluster.videos[0]);
        }
      }}
    >
      <View className={`rounded-full items-center justify-center ${
        cluster.count > 1 ? 'bg-red-500' : 'bg-primary'
      }`} style={{ 
        width: cluster.count > 1 ? 40 : 32, 
        height: cluster.count > 1 ? 40 : 32,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 4,
        elevation: 5,
      }}>
        {cluster.count > 1 ? (
          <Text className="text-white font-bold text-sm">{cluster.count}</Text>
        ) : (
          <Ionicons name="videocam" size={18} color="#FFFFFF" />
        )}
      </View>
    </Marker>
  );

  return (
    <View className="flex-1 bg-black">
      <MapView
        style={{ flex: 1 }}
        region={mapRegion}
        onRegionChangeComplete={setMapRegion}
        showsUserLocation
        showsMyLocationButton
        userLocationPriority="high"
        mapType="standard"
        showsCompass={false}
        showsScale={false}
      >
        {/* Render clustered video markers */}
        {clusterVideos.map(renderClusterMarker)}
      </MapView>

      {/* Top bar with location info */}
      {location && (
        <View className="absolute top-12 left-4 right-4 bg-black/80 rounded-xl p-3 flex-row items-center justify-between">
          <View className="flex-row items-center">
            <Ionicons name="location" size={16} color="#0A84FF" />
            <Text className="text-white text-sm font-medium ml-2">
              {videos.length} videos in your area
            </Text>
          </View>
          <TouchableOpacity
            onPress={fetchNearbyVideos}
            className="bg-primary rounded-full p-2"
          >
            <Ionicons name="refresh" size={18} color="#FFFFFF" />
          </TouchableOpacity>
        </View>
      )}

      {/* Selected video info */}
      {selectedVideo && (
        <View className="absolute bottom-6 left-4 right-4 bg-black/90 rounded-2xl p-4 border border-gray-800">
          <View className="flex-row items-center justify-between mb-3">
            <View className="flex-row items-center">
              <View className="w-8 h-8 bg-primary rounded-full items-center justify-center mr-3">
                <Text className="text-white text-xs font-bold">
                  {selectedVideo.user_id?.charAt(0).toUpperCase()}
                </Text>
              </View>
              <Text className="text-white font-semibold text-lg">
                @{selectedVideo.user_id}
              </Text>
            </View>
            <TouchableOpacity
              onPress={() => setSelectedVideo(null)}
              className="p-1 bg-gray-800 rounded-full"
            >
              <Ionicons name="close" size={18} color="#FFFFFF" />
            </TouchableOpacity>
          </View>
          
          {selectedVideo.caption && (
            <Text className="text-gray-300 mb-3 text-base" numberOfLines={2}>
              {selectedVideo.caption}
            </Text>
          )}
          
          <View className="flex-row items-center justify-between">
            <View className="flex-row items-center">
              <Ionicons name="location-outline" size={14} color="#8E8E93" />
              <Text className="text-gray-400 text-sm ml-1">
                {selectedVideo.distance < 1 
                  ? `${Math.round(selectedVideo.distance * 1000)}m away`
                  : `${selectedVideo.distance.toFixed(1)}km away`
                }
              </Text>
            </View>
            
            <TouchableOpacity 
              onPress={() => router.push(`/video/${selectedVideo.id}`)}
              className="bg-primary rounded-full px-6 py-2"
            >
              <Text className="text-white font-semibold">Watch</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
    </View>
  );
} 