import React, { useState, useRef } from 'react';
import { View, Text, TouchableOpacity, Dimensions } from 'react-native';
import { VideoView, useVideoPlayer } from 'expo-video';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/lib/supabase';
import { Database } from '@/types/database';

type VideoData = Database['public']['Functions']['get_nearby_videos']['Returns'][0];

interface VideoPlayerProps {
  video: VideoData;
}

const { width, height } = Dimensions.get('window');

export default function VideoPlayer({ video }: VideoPlayerProps) {
  const { user } = useAuth();
  const player = useVideoPlayer(video.video_url, (player) => {
    player.loop = true;
    player.play();
  });
  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(0);
  const [commentCount, setCommentCount] = useState(0);

  React.useEffect(() => {
    checkIfLiked();
    fetchCounts();
  }, [video.id]);

  const checkIfLiked = async () => {
    if (!user) return;
    
    try {
      const { data } = await supabase
        .from('likes')
        .select('id')
        .eq('user_id', user.id)
        .eq('video_id', video.id)
        .single();
      
      setIsLiked(!!data);
    } catch (error) {
      setIsLiked(false);
    }
  };

  const fetchCounts = async () => {
    try {
      // Get like count
      const { count: likes } = await supabase
        .from('likes')
        .select('*', { count: 'exact', head: true })
        .eq('video_id', video.id);
      
      // Get comment count
      const { count: comments } = await supabase
        .from('comments')
        .select('*', { count: 'exact', head: true })
        .eq('video_id', video.id);
      
      setLikeCount(likes || 0);
      setCommentCount(comments || 0);
    } catch (error) {
      console.error('Error fetching counts:', error);
    }
  };

  const toggleLike = async () => {
    if (!user) return;

    try {
      if (isLiked) {
        // Unlike
        await supabase
          .from('likes')
          .delete()
          .eq('user_id', user.id)
          .eq('video_id', video.id);
        setLikeCount(prev => prev - 1);
      } else {
        // Like
        await supabase
          .from('likes')
          .insert({
            user_id: user.id,
            video_id: video.id,
          });
        setLikeCount(prev => prev + 1);
      }
      setIsLiked(!isLiked);
    } catch (error) {
      console.error('Error toggling like:', error);
    }
  };

  const formatDistance = (distance: number) => {
    if (distance < 1) {
      return `${Math.round(distance * 1000)}m away`;
    }
    return `${distance.toFixed(1)}km away`;
  };

  return (
    <View className="flex-1 bg-background">
      <VideoView
        player={player}
        style={{ width, height }}
        contentFit="cover"
        nativeControls={false}
      />
      
      {/* Overlay */}
      <View className="absolute inset-0">
        {/* Top info */}
        <View className="absolute top-12 left-4 right-4 z-10">
          <Text className="text-text text-lg font-semibold mb-1">
            @{video.user_id}
          </Text>
          <Text className="text-text-secondary text-sm mb-2">
            {formatDistance(video.distance)}
          </Text>
          {video.caption && (
            <Text className="text-text text-base" numberOfLines={2}>
              {video.caption}
            </Text>
          )}
        </View>

        {/* Right side actions */}
        <View className="absolute right-4 bottom-20 space-y-6">
          <TouchableOpacity
            onPress={toggleLike}
            className="items-center"
          >
            <Ionicons
              name={isLiked ? 'heart' : 'heart-outline'}
              size={32}
              color={isLiked ? '#FF3B30' : '#FFFFFF'}
            />
            <Text className="text-text text-sm mt-1">{likeCount}</Text>
          </TouchableOpacity>

          <TouchableOpacity className="items-center">
            <Ionicons name="chatbubble-outline" size={32} color="#FFFFFF" />
            <Text className="text-text text-sm mt-1">{commentCount}</Text>
          </TouchableOpacity>

          <TouchableOpacity className="items-center">
            <Ionicons name="share-outline" size={32} color="#FFFFFF" />
            <Text className="text-text text-sm mt-1">Share</Text>
          </TouchableOpacity>
        </View>

        {/* Bottom controls */}
        <View className="absolute bottom-8 left-4 right-20">
          <View className="flex-row items-center space-x-2">
            <View className="w-1 h-8 bg-primary rounded-full" />
            <Text className="text-text-secondary text-sm">
              {Math.floor(player.currentTime || 0)}s
            </Text>
          </View>
        </View>
      </View>
    </View>
  );
} 