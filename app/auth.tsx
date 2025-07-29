import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, Alert, ActivityIndicator } from 'react-native';
import { useAuth } from '@/contexts/AuthContext';
import { Ionicons } from '@expo/vector-icons';

export default function AuthScreen() {
  const { signIn, signUp } = useAuth();
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [username, setUsername] = useState('');
  const [loading, setLoading] = useState(false);

  const handleAuth = async () => {
    if (!email || !password || (isSignUp && !username)) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    try {
      setLoading(true);
      if (isSignUp) {
        await signUp(email, password, username);
        Alert.alert('Success', 'Account created! Please check your email to verify your account.');
      } else {
        await signIn(email, password);
      }
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className="flex-1 bg-background justify-center px-6">
      {/* Logo */}
      <View className="items-center mb-12">
        <View className="w-20 h-20 bg-primary rounded-full items-center justify-center mb-4">
          <Ionicons name="videocam" size={40} color="#FFFFFF" />
        </View>
        <Text className="text-text text-3xl font-bold mb-2">Lenz</Text>
        <Text className="text-text-secondary text-center">
          Share your world through location-based videos
        </Text>
      </View>

      {/* Auth Form */}
      <View className="space-y-4">
        {isSignUp && (
          <TextInput
            placeholder="Username"
            placeholderTextColor="#8E8E93"
            value={username}
            onChangeText={setUsername}
            className="bg-surface rounded-lg p-4 text-text border border-border"
            autoCapitalize="none"
            autoCorrect={false}
          />
        )}

        <TextInput
          placeholder="Email"
          placeholderTextColor="#8E8E93"
          value={email}
          onChangeText={setEmail}
          className="bg-surface rounded-lg p-4 text-text border border-border"
          keyboardType="email-address"
          autoCapitalize="none"
          autoCorrect={false}
        />

        <TextInput
          placeholder="Password"
          placeholderTextColor="#8E8E93"
          value={password}
          onChangeText={setPassword}
          className="bg-surface rounded-lg p-4 text-text border border-border"
          secureTextEntry
        />

        <TouchableOpacity
          onPress={handleAuth}
          disabled={loading}
          className="bg-primary rounded-lg py-4 items-center"
        >
          {loading ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text className="text-text font-semibold text-lg">
              {isSignUp ? 'Sign Up' : 'Sign In'}
            </Text>
          )}
        </TouchableOpacity>
      </View>

      {/* Toggle Auth Mode */}
      <View className="flex-row justify-center mt-8">
        <Text className="text-text-secondary">
          {isSignUp ? 'Already have an account? ' : "Don't have an account? "}
        </Text>
        <TouchableOpacity onPress={() => setIsSignUp(!isSignUp)}>
          <Text className="text-primary font-semibold">
            {isSignUp ? 'Sign In' : 'Sign Up'}
          </Text>
        </TouchableOpacity>
      </View>

      {/* Features */}
      <View className="mt-12 space-y-4">
        <View className="flex-row items-center">
          <Ionicons name="location" size={20} color="#0A84FF" />
          <Text className="text-text-secondary ml-3">Discover videos near you</Text>
        </View>
        <View className="flex-row items-center">
          <Ionicons name="videocam" size={20} color="#0A84FF" />
          <Text className="text-text-secondary ml-3">Record and share short videos</Text>
        </View>
        <View className="flex-row items-center">
          <Ionicons name="map" size={20} color="#0A84FF" />
          <Text className="text-text-secondary ml-3">Explore content on an interactive map</Text>
        </View>
      </View>
    </View>
  );
} 