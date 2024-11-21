# Use the official Flutter image as the base image
FROM cirrusci/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Create a non-root user and switch to that user
RUN adduser --disabled-password --gecos "" flutteruser
USER flutteruser

# Copy the pubspec files and get dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the application code
COPY . .

# Build the Flutter web app
RUN flutter build web

# Use a lightweight web server to serve the Flutter web app
FROM nginx:alpine
