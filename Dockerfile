# ========================
# Stage 1: The Builder
# ========================
FROM rust:1.82-slim-bookworm AS builder

WORKDIR /usr/src/app
COPY . .

# Build the release binary. 
# --release enables high-level optimizations (critical for low latency)
RUN cargo build --release

# ========================
# Stage 2: The Runtime
# ========================
# We use debian:bookworm-slim for a balance of size and compatibility (OpenSSL)
FROM debian:bookworm-slim

# Install OpenSSL (often required for HTTPS requests) and ca-certificates
RUN apt-get update && apt-get install -y libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

# Create a non-root user (Security Best Practice)
# Running as root is a major security risk.
RUN useradd -ms /bin/bash appuser
USER appuser
WORKDIR /home/appuser

# Copy only the compiled binary from Stage 1
COPY --from=builder /usr/src/app/target/release/tauri-container ./server

# Expose the port
EXPOSE 8080

# Run the binary
CMD ["./server"]