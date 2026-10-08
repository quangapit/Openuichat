# ============================================
# Stage 1: Tự build Caddy từ nguồn
# ============================================
FROM golang:1.23-alpine AS caddy-builder

# Cài đặt các gói cần thiết để build
RUN apk add --no-cache git gcc musl-dev

# Cài đặt xcaddy
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# ⚠️ QUAN TRỌNG: Tắt setcap để binary không có file capabilities
ENV XCADDY_SETCAP=0

# Build Caddy (không kèm plugin nào)
RUN xcaddy build

# ============================================
# Stage 2: Image chính (Ollama + Caddy)
# ============================================
FROM ollama/ollama:latest

# Copy Caddy binary đã build từ stage 1
COPY --from=caddy-builder /go/caddy /usr/bin/caddy

# Đảm bảo quyền thực thi
RUN chmod +x /usr/bin/caddy

# Xóa mọi capabilities còn sót (lớp bảo hiểm thứ hai)
RUN setcap -r /usr/bin/caddy 2>/dev/null || true

# Tạo thư mục cấu hình cho Caddy
RUN mkdir -p /etc/caddy

# Copy file cấu hình Caddy
COPY Caddyfile /etc/caddy/Caddyfile

# Copy script khởi động
COPY start.sh /start.sh

# Chuyển đổi line ending (nếu có) và cấp quyền thực thi
RUN sed -i 's/\r$//' /start.sh && chmod +x /start.sh

# Biến môi trường cho Ollama
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_KEEP_ALIVE=24h

# Cổng mặc định (Render sẽ inject PORT)
ENV PORT=10000
EXPOSE 10000

# Chạy script khởi động
ENTRYPOINT ["/start.sh"]
