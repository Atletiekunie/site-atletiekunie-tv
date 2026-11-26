# Build stage - Build the Hugo site
FROM alpine:latest as builder

WORKDIR /src

# Install Hugo and git (needed for submodules)
RUN apk add --no-cache hugo git

# Copy site content
COPY . .

# Initialize and update git submodules (for themes)
RUN git config --global --add safe.directory /src && \
    git submodule update --init --recursive

# Debug: Check if theme is present
RUN ls -la themes/

# Build the Hugo site
RUN hugo --gc --minify

# Runtime stage - Serve with nginx
FROM nginx:1.31.10-alpine

LABEL org.opencontainers.image.title="Atletiekunie TV"
LABEL org.opencontainers.image.description="Atletiekunie TV Hugo site served by nginx"
LABEL org.opencontainers.image.source="https://github.com/Atletiekunie/site-atletiekunie-tv"

# Copy nginx config
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Hugo site from builder stage
COPY --from=builder /src/public /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
