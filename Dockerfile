# ============================================
# Stage 1: Lấy Caddy binary từ image chính thức
# ============================================
FROM caddy:2 AS caddy-builder

# ============================================
# Stage 2: Image chính (Ollama + Caddy)
# ============================================
FROM ollama/ollama:latest

# Copy Caddy binary từ stage 1
COPY --from=caddy-builder /usr/bin/caddy /usr/bin/caddy

# Tạo thư mục cấu hình cho Caddy
RUN mkdir -p /etc/caddy

# Copy file cấu hình Caddy
COPY Caddyfile /etc/caddy/Caddyfile

# Copy script khởi động
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Biến môi trường cho Ollama
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_KEEP_ALIVE=24h

# Cổng mặc định (Render sẽ inject PORT, nhưng đặt mặc định để chạy local)
ENV PORT=10000

# Expose cổng mà Render yêu cầu
EXPOSE 10000

# Khởi chạy
CMD ["/start.sh"]
