import { Stack } from 'expo-router';
import { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { AuthProvider } from '@/contexts/AuthContext';
import { LocationProvider } from '@/contexts/LocationContext';
import '../global.css';

export default function RootLayout() {
  return (
    <AuthProvider>
      <LocationProvider>
        <Stack
          screenOptions={{
            headerShown: false,
            contentStyle: { backgroundColor: '#000000' },
          }}
        >
          <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
          <Stack.Screen name="auth" options={{ headerShown: false }} />
          <Stack.Screen name="video/[id]" options={{ headerShown: false }} />
        </Stack>
        <StatusBar style="light" />
      </LocationProvider>
    </AuthProvider>
  );
} 