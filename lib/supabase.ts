import 'react-native-url-polyfill/auto';
import { createClient } from '@supabase/supabase-js';
import { Database } from '@/types/database';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: {
      async getItem(key: string) {
        // Implement secure storage for React Native
        return null;
      },
      async setItem(key: string, value: string) {
        // Implement secure storage for React Native
      },
      async removeItem(key: string) {
        // Implement secure storage for React Native
      },
    },
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

export type SupabaseClient = typeof supabase; 