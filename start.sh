#!/bin/sh
set -e

echo "🚀 Bắt đầu khởi động Ollama..."
ollama serve &
OLLAMA_PID=$!

echo "⏳ Chờ Ollama sẵn sàng..."
for i in $(seq 1 60); do
  if ollama list > /dev/null 2>&1; then
    echo "✅ Ollama đã sẵn sàng!"
    break
  fi
  sleep 1
done

# ============================================
# Tự động pull model (bỏ comment nếu muốn dùng)
# ============================================
# MODEL="qwen2.5-coder:7b"
# if ! ollama list | grep -q "$MODEL"; then
#   echo "📥 Đang pull model $MODEL..."
#   ollama pull "$MODEL" || echo "⚠️ Pull model thất bại."
# fi

echo "🔐 Khởi động proxy trên cổng $PORT..."
exec proxy
