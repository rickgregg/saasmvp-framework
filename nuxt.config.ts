// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  sourcemap: {
    server: true,
    client: true
  },
  modules: [
    '@saasmvp/nuxt-saasmvp-oauth'
  ],
})
