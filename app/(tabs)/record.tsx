import React, { useState, useRef, useEffect } from 'react';
import { View, Text, TouchableOpacity, TextInput, Alert, ActivityIndicator } from 'react-native';
import { Camera, CameraType, FlashMode } from 'expo-camera';
import { Video } from 'expo-av';
import * as Location from 'expo-location';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '@/contexts/AuthContext';
import { useLocation } from '@/contexts/LocationContext';
import { supabase } from '@/lib/supabase';
import * as FileSystem from 'expo-file-system';

export default function RecordScreen() {
  const { user } = useAuth();
  const { location } = useLocation();
  const cameraRef = useRef<Camera>(null);
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [isRecording, setIsRecording] = useState(false);
  const [recordedVideo, setRecordedVideo] = useState<string | null>(null);
  const [caption, setCaption] = useState('');
  const [uploading, setUploading] = useState(false);
  const [cameraType, setCameraType] = useState(CameraType.back);
  const [flashMode, setFlashMode] = useState(FlashMode.off);

  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      const audioStatus = await Camera.requestMicrophonePermissionsAsync();
      setHasPermission(status === 'granted' && audioStatus.status === 'granted');
    })();
  }, []);

  const startRecording = async () => {
    if (!cameraRef.current) return;

    try {
      setIsRecording(true);
      const video = await cameraRef.current.recordAsync({
        maxDuration: 60, // 60 seconds max
        quality: '720p',
      });
      setRecordedVideo(video.uri);
    } catch (error) {
      console.error('Error recording video:', error);
      Alert.alert('Error', 'Failed to record video');
    } finally {
      setIsRecording(false);
    }
  };

  const stopRecording = () => {
    if (cameraRef.current && isRecording) {
      cameraRef.current.stopRecording();
    }
  };

  const retakeVideo = () => {
    setRecordedVideo(null);
    setCaption('');
  };

  const uploadVideo = async () => {
    if (!user || !recordedVideo || !location) {
      Alert.alert('Error', 'Missing required data');
      return;
    }

    try {
      setUploading(true);

      // Upload video to Supabase Storage
      const fileName = `${user.id}_${Date.now()}.mp4`;
      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('videos')
        .upload(fileName, {
          uri: recordedVideo,
          type: 'video/mp4',
          name: fileName,
        });

      if (uploadError) throw uploadError;

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('videos')
        .getPublicUrl(fileName);

      // Save video record to database
      const { error: dbError } = await supabase
        .from('videos')
        .insert({
          user_id: user.id,
          video_url: urlData.publicUrl,
          caption: caption.trim() || null,
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
        });

      if (dbError) throw dbError;

      Alert.alert('Success', 'Video uploaded successfully!');
      retakeVideo();
    } catch (error) {
      console.error('Error uploading video:', error);
      Alert.alert('Error', 'Failed to upload video');
    } finally {
      setUploading(false);
    }
  };

  const toggleCameraType = () => {
    setCameraType(current => 
      current === CameraType.back ? CameraType.front : CameraType.back
    );
  };

  const toggleFlash = () => {
    setFlashMode(current => 
      current === FlashMode.off ? FlashMode.on : FlashMode.off
    );
  };

  if (hasPermission === null) {
    return (
      <View className="flex-1 bg-background justify-center items-center">
        <ActivityIndicator size="large" color="#0A84FF" />
      </View>
    );
  }

  if (hasPermission === false) {
    return (
      <View className="flex-1 bg-background justify-center items-center px-6">
        <Ionicons name="camera-outline" size={64} color="#8E8E93" />
        <Text className="text-text text-xl font-semibold text-center mt-4 mb-2">
          Camera Access Required
        </Text>
        <Text className="text-text-secondary text-center">
          Please enable camera and microphone access to record videos
        </Text>
      </View>
    );
  }

  if (recordedVideo) {
    return (
      <View className="flex-1 bg-background">
        <Video
          source={{ uri: recordedVideo }}
          style={{ flex: 1 }}
          resizeMode="cover"
          shouldPlay
          isLooping
        />
        
        {/* Overlay */}
        <View className="absolute inset-0 bg-black bg-opacity-50">
          <View className="flex-1 justify-end p-4">
            <TextInput
              placeholder="Add a caption..."
              placeholderTextColor="#8E8E93"
              value={caption}
              onChangeText={setCaption}
              className="bg-surface rounded-lg p-3 text-text mb-4"
              multiline
              maxLength={200}
            />
            
            <View className="flex-row space-x-4">
              <TouchableOpacity
                onPress={retakeVideo}
                className="flex-1 bg-surface rounded-lg py-3 items-center"
              >
                <Text className="text-text font-semibold">Retake</Text>
              </TouchableOpacity>
              
              <TouchableOpacity
                onPress={uploadVideo}
                disabled={uploading}
                className="flex-1 bg-primary rounded-lg py-3 items-center"
              >
                {uploading ? (
                  <ActivityIndicator color="#FFFFFF" />
                ) : (
                  <Text className="text-text font-semibold">Upload</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-background">
      <Camera
        ref={cameraRef}
        type={cameraType}
        flashMode={flashMode}
        style={{ flex: 1 }}
      >
        {/* Top controls */}
        <View className="absolute top-12 left-4 right-4 flex-row justify-between items-center">
          <TouchableOpacity
            onPress={toggleFlash}
            className="bg-black bg-opacity-50 rounded-full p-3"
          >
            <Ionicons
              name={flashMode === FlashMode.on ? 'flash' : 'flash-off'}
              size={24}
              color="#FFFFFF"
            />
          </TouchableOpacity>
          
          <TouchableOpacity
            onPress={toggleCameraType}
            className="bg-black bg-opacity-50 rounded-full p-3"
          >
            <Ionicons name="camera-reverse" size={24} color="#FFFFFF" />
          </TouchableOpacity>
        </View>

        {/* Bottom controls */}
        <View className="absolute bottom-8 left-0 right-0 items-center">
          <TouchableOpacity
            onPressIn={startRecording}
            onPressOut={stopRecording}
            className={`w-20 h-20 rounded-full items-center justify-center ${
              isRecording ? 'bg-red-500' : 'bg-white'
            }`}
          >
            <View className="w-16 h-16 rounded-full bg-primary" />
          </TouchableOpacity>
          
          <Text className="text-text mt-4 text-center">
            {isRecording ? 'Recording...' : 'Hold to record'}
          </Text>
        </View>
      </Camera>
    </View>
  );
} 