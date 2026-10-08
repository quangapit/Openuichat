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

# Cổng mặc định (Render sẽ inject PORT)
ENV PORT=10000
EXPOSE 10000

# ⚠️ QUAN TRỌNG: Ghi đè ENTRYPOINT mặc định của Ollama
# Base image ollama/ollama có ENTRYPOINT ["/bin/ollama"]
# Nếu không ghi đè, CMD sẽ bị hiểu là tham số của ollama → lỗi "unknown command"
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/start.sh"]
