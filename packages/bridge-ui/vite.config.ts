import { sentryVitePlugin } from '@sentry/vite-plugin';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import polyfillNode from 'rollup-plugin-polyfill-node';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    sourcemap: true, // Source map generation must be turned on
  },
  define: { global: 'globalThis' },
  plugins: [
    svelte(),
    polyfillNode(),
    sentryVitePlugin({
      org: process.env.SENTRY_ORG,
      project: process.env.SENTRY_PROJECT,
      authToken: process.env.SENTRY_AUTH_TOKEN,
    }),
  ],
});
