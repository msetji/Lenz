#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log('🚀 Lenz App Setup\n');

async function question(prompt) {
  return new Promise((resolve) => {
    rl.question(prompt, resolve);
  });
}

async function setup() {
  try {
    // Check if .env already exists
    const envPath = path.join(process.cwd(), '.env');
    if (fs.existsSync(envPath)) {
      const overwrite = await question('⚠️  .env file already exists. Overwrite? (y/N): ');
      if (overwrite.toLowerCase() !== 'y') {
        console.log('Setup cancelled.');
        process.exit(0);
      }
    }

    console.log('📋 Please provide your Supabase configuration:\n');

    const supabaseUrl = await question('Supabase Project URL: ');
    const supabaseAnonKey = await question('Supabase Anon Key: ');
    const googleMapsKey = await question('Google Maps API Key (optional): ');

    // Create .env file
    const envContent = `# Supabase Configuration
EXPO_PUBLIC_SUPABASE_URL=${supabaseUrl}
EXPO_PUBLIC_SUPABASE_ANON_KEY=${supabaseAnonKey}

# Google Maps Configuration (optional for enhanced map features)
EXPO_PUBLIC_GOOGLE_MAPS_API_KEY=${googleMapsKey || ''}
`;

    fs.writeFileSync(envPath, envContent);

    console.log('\n✅ Environment variables configured successfully!');
    console.log('\n📋 Next steps:');
    console.log('1. Set up your Supabase project:');
    console.log('   - Create a new project at https://supabase.com');
    console.log('   - Run the SQL schema from database/schema.sql');
    console.log('   - Create a storage bucket named "videos"');
    console.log('   - Set bucket permissions to public');
    console.log('\n2. Install dependencies:');
    console.log('   npm install');
    console.log('\n3. Start the development server:');
    console.log('   npx expo start');
    console.log('\n4. Run on your device:');
    console.log('   - Press "i" for iOS simulator');
    console.log('   - Press "a" for Android emulator');
    console.log('   - Scan QR code with Expo Go app');

  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    process.exit(1);
  } finally {
    rl.close();
  }
}

setup(); 