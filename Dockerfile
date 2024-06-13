################################################################################ 
# Dockerfile
# builds saasmvp nuxtapp docker image
# richard l. gregg
# november 9, 2023
# modified june 12, 2024
################################################################################

# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/engine/reference/builder/

ARG NODE_VERSION=20.2.0

################################################################################
# Use node image for base image for all stages.
FROM node:${NODE_VERSION}-alpine as base

# Set working directory for all build stages.
WORKDIR /usr/src/app


################################################################################
# Create a stage for installing production dependecies.
FROM base as deps

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage bind mounts to package.json and package-lock.json to avoid having to copy them
# into this layer.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
#    npm ci --omit=dev
     npm ci

################################################################################
# Create a stage for building the application.
FROM deps as build

# Download additional development dependencies before building, as some projects require
# "devDependencies" to be installed to build. If you don't need this, remove this step.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci

# Copy the rest of the source files into the image.
COPY . .

# Generate prisma client before build, otherwise nuxt application server can't access mysql
ENV DATABASE_URL="mysql://root:example@saasmvp-mysql:3306/saasmvp"
RUN npx prisma generate --schema=./database/schema.prisma

# Run the build script.
RUN npm run build

################################################################################
# Create a new stage to run the application with minimal runtime dependencies
# where the necessary files are copied from the build stage.
FROM base as final

# Use production node environment by default.
ENV NODE_ENV production

# Run the application as a non-root user.
# USER node
USER root

# Copy package.json so that package manager commands can be used.
COPY package.json .

# Copy additional required files
COPY ./server/smvp.oauth.json ./server/smvp.oauth.json

# Copy the production dependencies from the deps stage and also
# the built application from the build stage into the image.
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/.output ./.output

# Expose the port that the application listens on.
EXPOSE 3000

# Run the server.
CMD node .output/server/index.mjs

# Create and seed mysql database, need to do this after RUN starts the server.
USER root
COPY ./database ./database
ENV DATABASE_URL="mysql://root:example@saasmvp-mysql:3306/saasmvp"

# Install Bash
RUN apk update
RUN apk add bash

