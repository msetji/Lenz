import React, { useEffect, useState } from 'react';
import { View, Text, TouchableOpacity, FlatList, Image, Alert, ActivityIndicator } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/lib/supabase';
import { Database } from '@/types/database';
import VideoPlayer from '@/components/VideoPlayer';

type Video = Database['public']['Tables']['videos']['Row'];

export default function ProfileScreen() {
  const { user, profile, signOut } = useAuth();
  const [videos, setVideos] = useState<Video[]>([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    videos: 0,
    likes: 0,
    followers: 0,
    following: 0,
  });

  useEffect(() => {
    if (user) {
      fetchUserVideos();
      fetchUserStats();
    }
  }, [user]);

  const fetchUserVideos = async () => {
    if (!user) return;

    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('videos')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setVideos(data || []);
    } catch (error) {
      console.error('Error fetching user videos:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchUserStats = async () => {
    if (!user) return;

    try {
      // Get video count
      const { count: videoCount } = await supabase
        .from('videos')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', user.id);

      // Get total likes received
      const { count: likeCount } = await supabase
        .from('likes')
        .select('*', { count: 'exact', head: true })
        .eq('video_id', videos.map(v => v.id));

      // Get follower count
      const { count: followerCount } = await supabase
        .from('followers')
        .select('*', { count: 'exact', head: true })
        .eq('following_id', user.id);

      // Get following count
      const { count: followingCount } = await supabase
        .from('followers')
        .select('*', { count: 'exact', head: true })
        .eq('follower_id', user.id);

      setStats({
        videos: videoCount || 0,
        likes: likeCount || 0,
        followers: followerCount || 0,
        following: followingCount || 0,
      });
    } catch (error) {
      console.error('Error fetching user stats:', error);
    }
  };

  const handleSignOut = () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Sign Out', style: 'destructive', onPress: signOut },
      ]
    );
  };

  const renderVideo = ({ item }: { item: Video }) => (
    <View className="w-1/3 aspect-square">
      <VideoPlayer video={item} />
    </View>
  );

  if (!user || !profile) {
    return (
      <View className="flex-1 bg-background justify-center items-center">
        <ActivityIndicator size="large" color="#0A84FF" />
      </View>
    );
  }

  return (
    <View className="flex-1 bg-background">
      {/* Header */}
      <View className="pt-12 pb-6 px-4 border-b border-border">
        <View className="flex-row items-center justify-between mb-4">
          <Text className="text-text text-2xl font-bold">Profile</Text>
          <TouchableOpacity onPress={handleSignOut}>
            <Ionicons name="log-out-outline" size={24} color="#FF3B30" />
          </TouchableOpacity>
        </View>

        {/* Profile Info */}
        <View className="flex-row items-center mb-6">
          <View className="w-20 h-20 rounded-full bg-surface items-center justify-center mr-4">
            {profile.profile_pic_url ? (
              <Image
                source={{ uri: profile.profile_pic_url }}
                className="w-20 h-20 rounded-full"
              />
            ) : (
              <Ionicons name="person" size={40} color="#8E8E93" />
            )}
          </View>
          
          <View className="flex-1">
            <Text className="text-text text-xl font-semibold mb-1">
              @{profile.username}
            </Text>
            {profile.bio && (
              <Text className="text-text-secondary text-sm" numberOfLines={2}>
                {profile.bio}
              </Text>
            )}
          </View>
        </View>

        {/* Stats */}
        <View className="flex-row justify-around">
          <View className="items-center">
            <Text className="text-text text-xl font-bold">{stats.videos}</Text>
            <Text className="text-text-secondary text-sm">Videos</Text>
          </View>
          <View className="items-center">
            <Text className="text-text text-xl font-bold">{stats.likes}</Text>
            <Text className="text-text-secondary text-sm">Likes</Text>
          </View>
          <View className="items-center">
            <Text className="text-text text-xl font-bold">{stats.followers}</Text>
            <Text className="text-text-secondary text-sm">Followers</Text>
          </View>
          <View className="items-center">
            <Text className="text-text text-xl font-bold">{stats.following}</Text>
            <Text className="text-text-secondary text-sm">Following</Text>
          </View>
        </View>
      </View>

      {/* Videos Grid */}
      <View className="flex-1 px-2">
        {loading ? (
          <View className="flex-1 justify-center items-center">
            <ActivityIndicator size="large" color="#0A84FF" />
          </View>
        ) : videos.length === 0 ? (
          <View className="flex-1 justify-center items-center px-6">
            <Ionicons name="videocam-outline" size={64} color="#8E8E93" />
            <Text className="text-text text-xl font-semibold text-center mt-4 mb-2">
              No videos yet
            </Text>
            <Text className="text-text-secondary text-center">
              Start recording to share your first video!
            </Text>
          </View>
        ) : (
          <FlatList
            data={videos}
            renderItem={renderVideo}
            keyExtractor={(item) => item.id.toString()}
            numColumns={3}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={{ paddingBottom: 20 }}
          />
        )}
      </View>
    </View>
  );
} 