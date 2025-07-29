/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",
    "./contexts/**/*.{js,jsx,ts,tsx}",
  ],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: '#0A84FF',
        background: '#000000',
        surface: '#1C1C1E',
        text: '#FFFFFF',
        'text-secondary': '#8E8E93',
        border: '#38383A',
      },
    },
  },
  plugins: [],
} 