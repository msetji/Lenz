import React, { createContext, useContext, useEffect, useState } from 'react';
import * as Location from 'expo-location';

export interface PrivateLocation {
  coords: {
    latitude: number;
    longitude: number;
    accuracy: number | null;
  };
  timestamp: number;
}

interface LocationContextType {
  location: Location.LocationObject | null;
  privateLocation: PrivateLocation | null;
  errorMsg: string | null;
  loading: boolean;
  permissionStatus: Location.LocationPermissionResponse | null;
  requestLocationPermission: () => Promise<boolean>;
  getCurrentLocation: () => Promise<Location.LocationObject | null>;
  getPrivateLocation: (blurRadius?: number) => PrivateLocation | null;
  refreshLocation: () => Promise<void>;
}

const LocationContext = createContext<LocationContextType | undefined>(undefined);

export function LocationProvider({ children }: { children: React.ReactNode }) {
  const [location, setLocation] = useState<Location.LocationObject | null>(null);
  const [privateLocation, setPrivateLocation] = useState<PrivateLocation | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [permissionStatus, setPermissionStatus] = useState<Location.LocationPermissionResponse | null>(null);

  useEffect(() => {
    initializeLocation();
  }, []);

  const initializeLocation = async () => {
    try {
      setLoading(true);
      
      // Check existing permissions first
      const existingStatus = await Location.getForegroundPermissionsAsync();
      setPermissionStatus(existingStatus);
      
      if (existingStatus.status === 'granted') {
        await refreshLocation();
      } else {
        const hasPermission = await requestLocationPermission();
        if (hasPermission) {
          await refreshLocation();
        }
      }
    } catch (error) {
      setErrorMsg('Failed to initialize location');
      console.error('Location initialization error:', error);
    } finally {
      setLoading(false);
    }
  };

  const refreshLocation = async () => {
    const currentLocation = await getCurrentLocation();
    if (currentLocation) {
      setLocation(currentLocation);
      setPrivateLocation(createPrivateLocation(currentLocation));
    }
  };

  const requestLocationPermission = async (): Promise<boolean> => {
    try {
      const response = await Location.requestForegroundPermissionsAsync();
      setPermissionStatus(response);
      
      if (response.status !== 'granted') {
        setErrorMsg('Permission to access location was denied');
        return false;
      }
      
      setErrorMsg(null);
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
        timeInterval: 5000,
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

  // Create a private location with optional coordinate blurring for privacy
  const createPrivateLocation = (loc: Location.LocationObject): PrivateLocation => {
    return {
      coords: {
        latitude: loc.coords.latitude,
        longitude: loc.coords.longitude,
        accuracy: loc.coords.accuracy,
      },
      timestamp: loc.timestamp,
    };
  };

  // Get location with privacy blur (±25m default)
  const getPrivateLocation = (blurRadius: number = 25): PrivateLocation | null => {
    if (!location) return null;

    // Convert meters to degrees (rough approximation)
    const blurDegrees = blurRadius / 111320; // 1 degree ≈ 111320 meters
    
    // Add random blur within radius
    const randomBlur = () => (Math.random() - 0.5) * 2 * blurDegrees;
    
    return {
      coords: {
        latitude: location.coords.latitude + randomBlur(),
        longitude: location.coords.longitude + randomBlur(),
        accuracy: blurRadius,
      },
      timestamp: location.timestamp,
    };
  };

  const value = {
    location,
    privateLocation,
    errorMsg,
    loading,
    permissionStatus,
    requestLocationPermission,
    getCurrentLocation,
    getPrivateLocation,
    refreshLocation,
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