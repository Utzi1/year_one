# Dockerfile
FROM ubuntu:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    cmake \
    ninja-build \
    clang \
    build-essential \
    libssl-dev \
    pkg-config \
    libgtk-3-dev \
    chromium-browser

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"
RUN flutter doctor
RUN flutter config --no-analytics
RUN flutter config --enable-web

# Set up app directory
WORKDIR /app
COPY . .
RUN flutter pub get

# Build and run web
CMD ["flutter", "run", "--web-port", "8080", "--web-hostname", "0.0.0.0", "-d", "web-server"]
