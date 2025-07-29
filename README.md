# Lenz

A location-based short-form video sharing app that lets users discover and post trending content tied to real-world places. Built with a focus on geotagging, social discovery, and an interactive video feed similar to TikTok, but centered around local events and hotspots.

## 🚀 Features

- **TikTok-style Video Feed**: Vertical scrolling video feed with swipe navigation
- **Location-based Discovery**: Find videos near your current location
- **Interactive Map**: Explore videos on an interactive map with video pins
- **Video Recording**: Built-in camera with 60-second video recording
- **Social Features**: Like, comment, and follow other users
- **Real-time Location**: GPS-based video tagging and discovery
- **Dark Theme**: Beautiful dark UI with blue accents (#0A84FF)

## 🛠 Tech Stack

### Frontend
- **React Native** + **Expo SDK 50**
- **NativeWind** (Tailwind CSS for RN)
- **React Navigation v7** (bottom-tab + stack)
- **Expo AV** (video record/playback)
- **Expo Location** (GPS)
- **React Native Maps** (map tab, video pins)

### Backend
- **Supabase** (Auth, Postgres, Storage)
- **PostgreSQL** with spatial indexing
- **Row-Level Security** (RLS) enabled
- **Edge Functions** for location queries

## 📱 Screenshots

- **Home Feed**: Vertical video feed with TikTok-style navigation
- **Map View**: Interactive map showing nearby videos
- **Record**: Camera interface for video recording
- **Profile**: User profile with stats and video grid

## 🗄 Database Schema

The app uses a PostgreSQL database with the following tables:

- `users`: User profiles and authentication
- `videos`: Video posts with location data
- `likes`: Video likes
- `comments`: Video comments
- `followers`: User following relationships

### Key Features:
- Spatial indexing on video locations
- Haversine distance calculations
- Row-level security policies
- Automatic user profile creation

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ 
- Expo CLI
- iOS Simulator or Android Emulator
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Lenz
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up Supabase**
   - Create a new Supabase project
   - Run the SQL schema from `database/schema.sql`
   - Create a storage bucket named `videos`
   - Set up RLS policies

4. **Configure environment variables**
   ```bash
   cp env.example .env
   ```
   
   Add your Supabase credentials:
   ```
   EXPO_PUBLIC_SUPABASE_URL=your_supabase_project_url
   EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

5. **Start the development server**
   ```bash
   npx expo start
   ```

6. **Run on device/simulator**
   - Press `i` for iOS simulator
   - Press `a` for Android emulator
   - Scan QR code with Expo Go app

## 🔧 Configuration

### Supabase Setup

1. **Database**: Execute the schema in `database/schema.sql`
2. **Storage**: Create a `videos` bucket with public access
3. **RLS**: All tables have RLS enabled with appropriate policies
4. **Edge Functions**: The `get_nearby_videos` function is included

### Permissions

The app requires the following permissions:
- Camera access for video recording
- Microphone access for audio recording
- Location access for GPS tagging
- Photo library access for video selection

## 📁 Project Structure

```
Lenz/
├── app/                    # Expo Router app directory
│   ├── (tabs)/            # Bottom tab navigation
│   │   ├── index.tsx      # Home feed
│   │   ├── map.tsx        # Map view
│   │   ├── record.tsx     # Video recording
│   │   └── profile.tsx    # User profile
│   ├── auth.tsx           # Authentication screen
│   └── _layout.tsx        # Root layout
├── components/            # Reusable components
│   └── VideoPlayer.tsx    # Video player component
├── contexts/              # React contexts
│   ├── AuthContext.tsx    # Authentication state
│   └── LocationContext.tsx # Location state
├── lib/                   # Utility libraries
│   └── supabase.ts        # Supabase client
├── types/                 # TypeScript types
│   └── database.ts        # Database types
├── database/              # Database schema
│   └── schema.sql         # Complete database setup
└── assets/                # App assets
```

## 🎨 Design System

### Colors
- **Primary**: #0A84FF (Deep Blue)
- **Background**: #000000 (Black)
- **Surface**: #1C1C1E (Dark Gray)
- **Text**: #FFFFFF (White)
- **Text Secondary**: #8E8E93 (Light Gray)
- **Border**: #38383A (Medium Gray)

### Typography
- System fonts with native rendering
- Consistent spacing and sizing
- Dark theme optimized

## 🔒 Security

- **Row-Level Security**: All tables protected with RLS policies
- **Authentication**: Supabase Auth with email/password
- **File Upload**: Secure video upload to Supabase Storage
- **Location Privacy**: User controls location sharing

## 🚀 Deployment

### Expo Build
```bash
# Build for iOS
npx expo build:ios

# Build for Android
npx expo build:android
```

### EAS Build (Recommended)
```bash
# Install EAS CLI
npm install -g @expo/eas-cli

# Configure EAS
eas build:configure

# Build for production
eas build --platform all
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Check the [Expo documentation](https://docs.expo.dev/)
- Review [Supabase documentation](https://supabase.com/docs)
- Open an issue in this repository

## 🔮 Future Enhancements

- **Real-time Comments**: Live comment updates
- **Video Filters**: AR filters and effects
- **Push Notifications**: New video alerts
- **Offline Support**: Cached video playback
- **Analytics**: User engagement metrics
- **Moderation**: Content filtering and reporting
