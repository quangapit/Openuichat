# ============================================
# Stage 1: Build proxy Go
# ============================================
FROM golang:1.23-alpine AS proxy-builder
WORKDIR /build
COPY proxy.go .
# Build static binary, không cần CGO
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o proxy proxy.go

# ============================================
# Stage 2: Image chính (Ollama + proxy)
# ============================================
FROM ollama/ollama:latest

# Copy binary proxy đã build
COPY --from=proxy-builder /build/proxy /usr/local/bin/proxy
RUN chmod +x /usr/local/bin/proxy

# Copy script khởi động
COPY start.sh /start.sh
RUN sed -i 's/\r$//' /start.sh && chmod +x /start.sh

# Biến môi trường cho Ollama
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_KEEP_ALIVE=24h

# Cổng mặc định (Render sẽ inject PORT)
ENV PORT=10000
EXPOSE 10000

# Chạy script khởi động
ENTRYPOINT ["/start.sh"]
