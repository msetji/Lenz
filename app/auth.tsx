import React, { useEffect } from 'react';
import { useRouter } from 'expo-router';

export default function AuthScreen() {
  const router = useRouter();

  useEffect(() => {
    // Redirect to signin by default
    router.replace('/signin');
  }, []);

  return null;
} 