import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, Alert, ActivityIndicator, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '@/contexts/AuthContext';
import { Ionicons } from '@expo/vector-icons';

export default function SignInScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const { signIn } = useAuth();
  const router = useRouter();

  const validateEmail = (email: string) => {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  };

  const handleSignIn = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    if (!validateEmail(email)) {
      Alert.alert('Error', 'Please enter a valid email address');
      return;
    }

    try {
      setLoading(true);
      await signIn(email, password);
      router.replace('/(tabs)');
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Sign in failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView 
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'} 
      className="flex-1 bg-white"
    >
      <ScrollView 
        contentContainerStyle={{ flexGrow: 1, justifyContent: 'center', paddingHorizontal: 24 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Logo */}
        <View className="items-center mb-12">
          <View className="w-24 h-24 bg-blue-500 rounded-full items-center justify-center mb-6">
            <Ionicons name="videocam" size={48} color="#FFFFFF" />
          </View>
          <Text className="text-black text-4xl font-bold mb-3">Welcome Back</Text>
          <Text className="text-gray-600 text-lg text-center">
            Sign in to continue sharing your world
          </Text>
        </View>

        {/* Sign In Form */}
        <View className="space-y-6">
          <View>
            <Text className="text-black text-sm font-medium mb-2">Email</Text>
            <TextInput
              placeholder="Enter your email"
              placeholderTextColor="#9CA3AF"
              value={email}
              onChangeText={setEmail}
              className="bg-gray-50 rounded-xl px-4 py-4 text-black text-base border border-gray-300"
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>

          <View>
            <Text className="text-black text-sm font-medium mb-2">Password</Text>
            <View className="relative">
              <TextInput
                placeholder="Enter your password"
                placeholderTextColor="#9CA3AF"
                value={password}
                onChangeText={setPassword}
                className="bg-gray-50 rounded-xl px-4 py-4 pr-12 text-black text-base border border-gray-300"
                secureTextEntry={!showPassword}
              />
              <TouchableOpacity
                onPress={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-4"
              >
                <Ionicons 
                  name={showPassword ? 'eye-off' : 'eye'} 
                  size={20} 
                  color="#6B7280" 
                />
              </TouchableOpacity>
            </View>
          </View>

          <TouchableOpacity
            onPress={handleSignIn}
            disabled={loading}
            className={`rounded-xl py-4 items-center ${
              loading ? 'bg-gray-400' : 'bg-blue-500'
            }`}
          >
            {loading ? (
              <ActivityIndicator color="#FFFFFF" size="small" />
            ) : (
              <Text className="text-white font-semibold text-lg">
                Sign In
              </Text>
            )}
          </TouchableOpacity>
        </View>

        {/* Sign Up Link */}
        <View className="flex-row justify-center mt-8">
          <Text className="text-gray-600 text-base">
            Don't have an account? 
          </Text>
          <TouchableOpacity onPress={() => router.push('/signup')}>
            <Text className="text-blue-500 font-semibold text-base ml-1">
              Sign Up
            </Text>
          </TouchableOpacity>
        </View>

        {/* Features */}
        <View className="mt-16 space-y-6">
          <View className="flex-row items-center">
            <View className="w-8 h-8 bg-blue-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="location" size={16} color="#3B82F6" />
            </View>
            <Text className="text-gray-600 flex-1">Discover videos near you</Text>
          </View>
          <View className="flex-row items-center">
            <View className="w-8 h-8 bg-blue-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="videocam" size={16} color="#3B82F6" />
            </View>
            <Text className="text-gray-600 flex-1">Record and share short videos</Text>
          </View>
          <View className="flex-row items-center">
            <View className="w-8 h-8 bg-blue-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="map" size={16} color="#3B82F6" />
            </View>
            <Text className="text-gray-600 flex-1">Explore content on an interactive map</Text>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}