import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, Alert, ActivityIndicator, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '@/contexts/AuthContext';
import { Ionicons } from '@expo/vector-icons';

export default function SignUpScreen() {
  const [email, setEmail] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const { signUp } = useAuth();
  const router = useRouter();

  const validateEmail = (email: string) => {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  };

  const validatePassword = (password: string) => {
    return password.length >= 6;
  };

  const validateUsername = (username: string) => {
    return /^[a-zA-Z0-9_]{3,20}$/.test(username);
  };

  const handleSignUp = async () => {
    if (!email || !username || !password || !confirmPassword) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    if (!validateEmail(email)) {
      Alert.alert('Error', 'Please enter a valid email address');
      return;
    }

    if (!validateUsername(username)) {
      Alert.alert('Error', 'Username must be 3-20 characters long and contain only letters, numbers, and underscores');
      return;
    }

    if (!validatePassword(password)) {
      Alert.alert('Error', 'Password must be at least 6 characters long');
      return;
    }

    if (password !== confirmPassword) {
      Alert.alert('Error', 'Passwords do not match');
      return;
    }

    try {
      setLoading(true);
      await signUp(email, password, username);
      Alert.alert(
        'Success', 
        'Account created successfully! You can now sign in.',
        [{ text: 'OK', onPress: () => router.replace('/signin') }]
      );
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Sign up failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView 
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'} 
      className="flex-1 bg-black"
    >
      <ScrollView 
        contentContainerStyle={{ flexGrow: 1, justifyContent: 'center', paddingHorizontal: 24 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View className="flex-row items-center justify-between mb-8">
          <TouchableOpacity 
            onPress={() => router.back()}
            className="w-10 h-10 bg-gray-800 rounded-full items-center justify-center"
          >
            <Ionicons name="arrow-back" size={20} color="#FFFFFF" />
          </TouchableOpacity>
          <Text className="text-white text-lg font-semibold">Create Account</Text>
          <View className="w-10 h-10" />
        </View>

        {/* Logo */}
        <View className="items-center mb-12">
          <View className="w-20 h-20 bg-blue-500 rounded-full items-center justify-center mb-4">
            <Ionicons name="videocam" size={40} color="#FFFFFF" />
          </View>
          <Text className="text-white text-3xl font-bold mb-2">Join Lenz</Text>
          <Text className="text-gray-400 text-base text-center">
            Create your account to start sharing videos
          </Text>
        </View>

        {/* Sign Up Form */}
        <View className="space-y-5">
          <View>
            <Text className="text-white text-sm font-medium mb-2">Email Address</Text>
            <TextInput
              placeholder="Enter your email"
              placeholderTextColor="#6B7280"
              value={email}
              onChangeText={setEmail}
              className="bg-gray-800 rounded-xl px-4 py-4 text-white text-base border border-gray-700 focus:border-blue-500"
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>

          <View>
            <Text className="text-white text-sm font-medium mb-2">Username</Text>
            <TextInput
              placeholder="Choose a username (3-20 characters)"
              placeholderTextColor="#6B7280"
              value={username}
              onChangeText={setUsername}
              className="bg-gray-800 rounded-xl px-4 py-4 text-white text-base border border-gray-700 focus:border-blue-500"
              autoCapitalize="none"
              autoCorrect={false}
            />
            <Text className="text-gray-500 text-xs mt-1">
              Letters, numbers, and underscores only
            </Text>
          </View>

          <View>
            <Text className="text-white text-sm font-medium mb-2">Password</Text>
            <View className="relative">
              <TextInput
                placeholder="Create a password (min 6 characters)"
                placeholderTextColor="#6B7280"
                value={password}
                onChangeText={setPassword}
                className="bg-gray-800 rounded-xl px-4 py-4 pr-12 text-white text-base border border-gray-700 focus:border-blue-500"
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

          <View>
            <Text className="text-white text-sm font-medium mb-2">Confirm Password</Text>
            <View className="relative">
              <TextInput
                placeholder="Confirm your password"
                placeholderTextColor="#6B7280"
                value={confirmPassword}
                onChangeText={setConfirmPassword}
                className="bg-gray-800 rounded-xl px-4 py-4 pr-12 text-white text-base border border-gray-700 focus:border-blue-500"
                secureTextEntry={!showConfirmPassword}
              />
              <TouchableOpacity
                onPress={() => setShowConfirmPassword(!showConfirmPassword)}
                className="absolute right-4 top-4"
              >
                <Ionicons 
                  name={showConfirmPassword ? 'eye-off' : 'eye'} 
                  size={20} 
                  color="#6B7280" 
                />
              </TouchableOpacity>
            </View>
          </View>

          <TouchableOpacity
            onPress={handleSignUp}
            disabled={loading}
            className={`rounded-xl py-4 items-center mt-6 ${
              loading ? 'bg-gray-700' : 'bg-blue-500'
            }`}
          >
            {loading ? (
              <ActivityIndicator color="#FFFFFF" size="small" />
            ) : (
              <Text className="text-white font-semibold text-lg">
                Create Account
              </Text>
            )}
          </TouchableOpacity>
        </View>

        {/* Sign In Link */}
        <View className="flex-row justify-center mt-8">
          <Text className="text-gray-400 text-base">
            Already have an account? 
          </Text>
          <TouchableOpacity onPress={() => router.replace('/signin')}>
            <Text className="text-blue-500 font-semibold text-base ml-1">
              Sign In
            </Text>
          </TouchableOpacity>
        </View>

        {/* Terms */}
        <Text className="text-gray-500 text-xs text-center mt-8 leading-4">
          By creating an account, you agree to our Terms of Service and Privacy Policy
        </Text>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}