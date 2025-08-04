import React, { useState, useRef, useEffect } from 'react';
import { View, Text, TouchableOpacity, TextInput, Alert, ActivityIndicator, Dimensions, Animated } from 'react-native';
import { Camera, CameraType, FlashMode } from 'expo-camera';
import { VideoView, useVideoPlayer } from 'expo-video';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '@/contexts/AuthContext';
import { useLocation } from '@/contexts/LocationContext';
import { supabase } from '@/lib/supabase';

const { width, height } = Dimensions.get('window');

export default function RecordScreen() {
  const { user } = useAuth();
  const { location, getPrivateLocation } = useLocation();
  const cameraRef = useRef<Camera>(null);
  const recordingAnimation = useRef(new Animated.Value(1)).current;
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [isRecording, setIsRecording] = useState(false);
  const [recordedVideo, setRecordedVideo] = useState<string | null>(null);
  const [caption, setCaption] = useState('');
  const [uploading, setUploading] = useState(false);
  const [cameraType, setCameraType] = useState(CameraType.back);
  const [flashMode, setFlashMode] = useState(FlashMode.off);
  const [recordingTime, setRecordingTime] = useState(0);
  const [maxDuration] = useState(60); // 60 seconds max
  
  const player = useVideoPlayer(recordedVideo || '', (player) => {
    player.loop = true;
    player.play();
  });

  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      const audioStatus = await Camera.requestMicrophonePermissionsAsync();
      setHasPermission(status === 'granted' && audioStatus.status === 'granted');
    })();
  }, []);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (isRecording) {
      // Start pulsing animation
      Animated.loop(
        Animated.sequence([
          Animated.timing(recordingAnimation, {
            toValue: 1.2,
            duration: 500,
            useNativeDriver: true,
          }),
          Animated.timing(recordingAnimation, {
            toValue: 1,
            duration: 500,
            useNativeDriver: true,
          }),
        ])
      ).start();

      // Start timer
      interval = setInterval(() => {
        setRecordingTime(prev => {
          if (prev >= maxDuration - 1) {
            stopRecording();
            return maxDuration;
          }
          return prev + 1;
        });
      }, 1000);
    } else {
      recordingAnimation.setValue(1);
      setRecordingTime(0);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isRecording]);

  const startRecording = async () => {
    if (!cameraRef.current || !location) {
      Alert.alert('Error', 'Camera or location not available');
      return;
    }

    try {
      setIsRecording(true);
      const video = await cameraRef.current.recordAsync({
        maxDuration: maxDuration,
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
    if (!user || !recordedVideo) {
      Alert.alert('Error', 'Missing required data');
      return;
    }

    // Get private location with blur for privacy
    const privateLocation = getPrivateLocation(25); // 25m blur radius
    if (!privateLocation) {
      Alert.alert('Error', 'Location not available');
      return;
    }

    try {
      setUploading(true);

      // Create form data for video upload
      const formData = new FormData();
      formData.append('file', {
        uri: recordedVideo,
        type: 'video/mp4',
        name: `video_${Date.now()}.mp4`,
      } as any);

      // Upload video to Supabase Storage
      const fileName = `${user.id}_${Date.now()}.mp4`;
      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('videos')
        .upload(fileName, formData);

      if (uploadError) throw uploadError;

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('videos')
        .getPublicUrl(fileName);

      // Save video record to database with private location
      const { error: dbError } = await supabase
        .from('videos')
        .insert({
          user_id: user.id,
          video_url: urlData.publicUrl,
          caption: caption.trim() || null,
          latitude: privateLocation.coords.latitude,
          longitude: privateLocation.coords.longitude,
        });

      if (dbError) throw dbError;

      Alert.alert('Success', 'Video uploaded successfully!', [
        { text: 'OK', onPress: retakeVideo }
      ]);
    } catch (error) {
      console.error('Error uploading video:', error);
      Alert.alert('Error', 'Failed to upload video. Please try again.');
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
        <VideoView
          player={player}
          style={{ flex: 1 }}
          contentFit="cover"
          nativeControls={false}
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
        <View className="absolute top-12 left-4 right-4 flex-row justify-between items-center z-10">
          <TouchableOpacity
            onPress={toggleFlash}
            className="bg-black/60 rounded-full p-3"
          >
            <Ionicons
              name={flashMode === FlashMode.on ? 'flash' : 'flash-off'}
              size={24}
              color="#FFFFFF"
            />
          </TouchableOpacity>

          {/* Recording timer */}
          {isRecording && (
            <View className="bg-red-500 rounded-full px-4 py-2 flex-row items-center">
              <View className="w-2 h-2 bg-white rounded-full mr-2" />
              <Text className="text-white font-mono text-lg">
                {Math.floor(recordingTime / 60)}:{(recordingTime % 60).toString().padStart(2, '0')}
              </Text>
            </View>
          )}
          
          <TouchableOpacity
            onPress={toggleCameraType}
            className="bg-black/60 rounded-full p-3"
          >
            <Ionicons name="camera-reverse" size={24} color="#FFFFFF" />
          </TouchableOpacity>
        </View>

        {/* Progress bar */}
        {isRecording && (
          <View className="absolute top-20 left-4 right-4 mt-16">
            <View className="h-1 bg-white/30 rounded-full">
              <View 
                className="h-1 bg-red-500 rounded-full"
                style={{ width: `${(recordingTime / maxDuration) * 100}%` }}
              />
            </View>
          </View>
        )}

        {/* Bottom controls */}
        <View className="absolute bottom-8 left-0 right-0 items-center">
          <Animated.View style={{ transform: [{ scale: recordingAnimation }] }}>
            <TouchableOpacity
              onPressIn={startRecording}
              onPressOut={stopRecording}
              disabled={isRecording && recordingTime >= maxDuration}
              className={`w-20 h-20 rounded-full items-center justify-center border-4 ${
                isRecording ? 'bg-red-500 border-red-300' : 'bg-white border-white/30'
              }`}
            >
              <View className={`rounded-full ${
                isRecording ? 'w-8 h-8 bg-white' : 'w-16 h-16 bg-red-500'
              }`} />
            </TouchableOpacity>
          </Animated.View>
          
          <Text className="text-white mt-4 text-center font-medium">
            {isRecording ? `Recording... ${maxDuration - recordingTime}s left` : 'Hold to record'}
          </Text>

          {!isRecording && (
            <Text className="text-white/70 mt-2 text-center text-sm">
              Max {maxDuration} seconds
            </Text>
          )}
        </View>
      </Camera>
    </View>
  );
} 