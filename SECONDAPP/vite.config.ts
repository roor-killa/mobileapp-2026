import { defineConfig } from 'vite'
import path from 'path'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'

const jsonServerProxy = {
  '/json-api': {
    target: 'http://127.0.0.1:3001',
    changeOrigin: true,
    rewrite: (path: string) => path.replace(/^\/json-api/, '') || '/',
  },
} as const;

export default defineConfig({
  server: {
    proxy: jsonServerProxy,
  },
  preview: {
    proxy: jsonServerProxy,
  },
  plugins: [
    // The React and Tailwind plugins are both required for Make, even if
    // Tailwind is not being actively used – do not remove them
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      // Alias @ to the src directory
      '@': path.resolve(__dirname, './src'),
    },
  },

  // File types to support raw imports. Never add .css, .tsx, or .ts files to this.
  assetsInclude: ['**/*.svg', '**/*.csv'],
})
