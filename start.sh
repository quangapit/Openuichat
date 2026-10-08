#!/bin/sh
set -e
ollama serve &
for i in $(seq 1 60); do
  if ollama list > /dev/null 2>&1; then break; fi
  sleep 1
done
# MODEL="qwen2.5-coder:7b"
# if ! ollama list | grep -q "$MODEL"; then
#   ollama pull "$MODEL" || true
# fi
nginx -g 'daemon off;'
