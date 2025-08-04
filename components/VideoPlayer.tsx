import React, { useState, useRef, useEffect } from 'react';
import { View, Text, TouchableOpacity, Dimensions, Animated, Share } from 'react-native';
import { VideoView, useVideoPlayer } from 'expo-video';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/lib/supabase';
import { Database } from '@/types/database';

type VideoData = Database['public']['Functions']['get_nearby_videos']['Returns'][0];

interface VideoPlayerProps {
  video: VideoData;
  isActive?: boolean;
  onPress?: () => void;
}

const { width, height } = Dimensions.get('window');

export default function VideoPlayer({ video, isActive = false, onPress }: VideoPlayerProps) {
  const { user } = useAuth();
  const likeAnimation = useRef(new Animated.Value(1)).current;
  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(0);
  const [commentCount, setCommentCount] = useState(0);
  const [isPlaying, setIsPlaying] = useState(isActive);
  
  const player = useVideoPlayer(video.video_url, (player) => {
    player.loop = true;
    if (isActive) {
      player.play();
    } else {
      player.pause();
    }
  });

  useEffect(() => {
    if (isActive && player) {
      player.play();
      setIsPlaying(true);
    } else if (player) {
      player.pause();
      setIsPlaying(false);
    }
  }, [isActive, player]);

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

    // Animate like button
    Animated.sequence([
      Animated.timing(likeAnimation, {
        toValue: 1.3,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.timing(likeAnimation, {
        toValue: 1,
        duration: 100,
        useNativeDriver: true,
      }),
    ]).start();

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

  const handleShare = async () => {
    try {
      await Share.share({
        message: `Check out this video on Lenz! ${video.caption || ''}`,
        url: video.video_url,
      });
    } catch (error) {
      console.error('Error sharing:', error);
    }
  };

  const togglePlayPause = () => {
    if (isPlaying) {
      player?.pause();
    } else {
      player?.play();
    }
    setIsPlaying(!isPlaying);
  };

  const formatDistance = (distance: number) => {
    if (distance < 1) {
      return `${Math.round(distance * 1000)}m away`;
    }
    return `${distance.toFixed(1)}km away`;
  };

  return (
    <TouchableOpacity 
      className="flex-1 bg-black" 
      onPress={onPress || togglePlayPause}
      activeOpacity={1}
    >
      <VideoView
        player={player}
        style={{ width, height }}
        contentFit="cover"
        nativeControls={false}
      />
      
      {/* Gradient overlay */}
      <View className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
      
      {/* Play/Pause indicator */}
      {!isPlaying && (
        <View className="absolute inset-0 items-center justify-center">
          <View className="bg-black/50 rounded-full p-4">
            <Ionicons name="play" size={40} color="#FFFFFF" />
          </View>
        </View>
      )}

      {/* Top info */}
      <View className="absolute top-12 left-4 right-4 z-10">
        <View className="flex-row items-center mb-2">
          <View className="w-8 h-8 bg-primary rounded-full items-center justify-center mr-3">
            <Text className="text-white text-xs font-bold">
              {video.user_id?.charAt(0).toUpperCase()}
            </Text>
          </View>
          <Text className="text-white text-lg font-semibold">
            @{video.user_id}
          </Text>
        </View>
        
        <View className="flex-row items-center mb-2">
          <Ionicons name="location" size={14} color="#8E8E93" />
          <Text className="text-gray-300 text-sm ml-1">
            {formatDistance(video.distance)}
          </Text>
        </View>

        {video.caption && (
          <Text className="text-white text-base leading-5" numberOfLines={3}>
            {video.caption}
          </Text>
        )}
      </View>

      {/* Right side actions */}
      <View className="absolute right-4 bottom-24 space-y-6">
        <Animated.View style={{ transform: [{ scale: likeAnimation }] }}>
          <TouchableOpacity
            onPress={toggleLike}
            className="items-center"
          >
            <View className={`w-12 h-12 rounded-full items-center justify-center ${
              isLiked ? 'bg-red-500/20' : 'bg-black/30'
            }`}>
              <Ionicons
                name={isLiked ? 'heart' : 'heart-outline'}
                size={28}
                color={isLiked ? '#FF3B30' : '#FFFFFF'}
              />
            </View>
            <Text className="text-white text-xs mt-1 font-medium">
              {likeCount > 0 ? likeCount : ''}
            </Text>
          </TouchableOpacity>
        </Animated.View>

        <TouchableOpacity className="items-center">
          <View className="w-12 h-12 rounded-full bg-black/30 items-center justify-center">
            <Ionicons name="chatbubble-outline" size={28} color="#FFFFFF" />
          </View>
          <Text className="text-white text-xs mt-1 font-medium">
            {commentCount > 0 ? commentCount : ''}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={handleShare} className="items-center">
          <View className="w-12 h-12 rounded-full bg-black/30 items-center justify-center">
            <Ionicons name="arrow-redo-outline" size={28} color="#FFFFFF" />
          </View>
          <Text className="text-white text-xs mt-1 font-medium">Share</Text>
        </TouchableOpacity>
      </View>

      {/* Bottom progress indicator */}
      <View className="absolute bottom-8 left-4 right-20">
        <View className="flex-row items-center">
          <View className="flex-1 h-1 bg-white/20 rounded-full mr-3">
            <View 
              className="h-1 bg-white rounded-full"
              style={{ 
                width: `${((player?.currentTime || 0) / (player?.duration || 1)) * 100}%` 
              }}
            />
          </View>
          <Text className="text-white text-xs font-mono">
            {Math.floor((player?.currentTime || 0) / 60)}:
            {Math.floor((player?.currentTime || 0) % 60).toString().padStart(2, '0')}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );
} 