import React, { createContext, useContext, useEffect, useState } from 'react';
import * as Location from 'expo-location';

interface LocationContextType {
  location: Location.LocationObject | null;
  errorMsg: string | null;
  loading: boolean;
  requestLocationPermission: () => Promise<boolean>;
  getCurrentLocation: () => Promise<Location.LocationObject | null>;
}

const LocationContext = createContext<LocationContextType | undefined>(undefined);

export function LocationProvider({ children }: { children: React.ReactNode }) {
  const [location, setLocation] = useState<Location.LocationObject | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    initializeLocation();
  }, []);

  const initializeLocation = async () => {
    try {
      setLoading(true);
      const hasPermission = await requestLocationPermission();
      
      if (hasPermission) {
        const currentLocation = await getCurrentLocation();
        if (currentLocation) {
          setLocation(currentLocation);
        }
      }
    } catch (error) {
      setErrorMsg('Failed to initialize location');
      console.error('Location initialization error:', error);
    } finally {
      setLoading(false);
    }
  };

  const requestLocationPermission = async (): Promise<boolean> => {
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      
      if (status !== 'granted') {
        setErrorMsg('Permission to access location was denied');
        return false;
      }
      
      return true;
    } catch (error) {
      setErrorMsg('Failed to request location permission');
      return false;
    }
  };

  const getCurrentLocation = async (): Promise<Location.LocationObject | null> => {
    try {
      const currentLocation = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });
      
      setLocation(currentLocation);
      setErrorMsg(null);
      return currentLocation;
    } catch (error) {
      setErrorMsg('Failed to get current location');
      console.error('Get current location error:', error);
      return null;
    }
  };

  const value = {
    location,
    errorMsg,
    loading,
    requestLocationPermission,
    getCurrentLocation,
  };

  return (
    <LocationContext.Provider value={value}>
      {children}
    </LocationContext.Provider>
  );
}

export function useLocation() {
  const context = useContext(LocationContext);
  if (context === undefined) {
    throw new Error('useLocation must be used within a LocationProvider');
  }
  return context;
} 