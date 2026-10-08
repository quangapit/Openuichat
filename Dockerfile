FROM ollama/ollama:latest
# Render yêu cầu service phải lắng nghe trên một cổng cụ thể (thường là 10000)
ENV OLLAMA_HOST=0.0.0.0:10000
EXPOSE 10000
