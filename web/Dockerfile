# Flutter se instala desde el repositorio oficial para poder fijar la versión exacta
# (las imágenes de cirruslabs solo llegan a 3.44.0 / Dart 3.12, y el proyecto pide Dart ^3.13.3)
FROM debian:bookworm-slim AS build
ARG FLUTTER_VERSION=3.47.7
ARG PUBLIC_BASE_URL=http://localhost:8085

RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl unzip xz-utils ca-certificates libglu1-mesa \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"
RUN git config --global --add safe.directory /flutter \
 && flutter config --no-analytics --enable-web \
 && flutter precache --web

WORKDIR /app
COPY app_movil/ .
RUN flutter pub get \
 && flutter build web --release --dart-define=PUBLIC_BASE_URL=${PUBLIC_BASE_URL}

FROM nginx:1.27-alpine
COPY web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
