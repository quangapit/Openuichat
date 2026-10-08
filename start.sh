#!/bin/sh
set -e

echo "🚀 Bắt đầu khởi động Ollama..."
ollama serve &
OLLAMA_PID=$!

echo "⏳ Chờ Ollama sẵn sàng..."
for i in $(seq 1 30); do
  if ollama list > /dev/null 2>&1; then
    echo "✅ Ollama đã sẵn sàng!"
    break
  fi
  sleep 1
done

echo "🔐 Khởi động Caddy reverse proxy trên cổng $PORT..."
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
