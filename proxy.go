package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"time"
)

func main() {
	apiKey := os.Getenv("OLLAMA_API_KEY")
	port := os.Getenv("PORT")
	if port == "" {
		port = "10000"
	}
	if apiKey == "" {
		log.Fatal("OLLAMA_API_KEY chưa được set")
	}

	// Ollama chạy nội bộ trên cổng 11434
	target, err := url.Parse("http://127.0.0.1:11434")
	if err != nil {
		log.Fatal(err)
	}

	proxy := httputil.NewSingleHostReverseProxy(target)
	// FlushInterval quan trọng cho streaming response của LLM
	proxy.FlushInterval = 100 * time.Millisecond

	// Tăng timeout transport cho các request generate dài
	proxy.Transport = &http.Transport{
		ResponseHeaderTimeout: 600 * time.Second,
		IdleConnTimeout:       600 * time.Second,
	}

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Health check - không cần auth
		if r.URL.Path == "/health" {
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("OK"))
			return
		}

		// Kiểm tra Bearer token
		if r.Header.Get("Authorization") != "Bearer "+apiKey {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			w.Write([]byte(`{"error":"Unauthorized. Provide a valid API key."}`))
			return
		}

		// Forward đến Ollama
		proxy.ServeHTTP(w, r)
	})

	log.Printf("🚀 Proxy listening on :%s", port)
	if err := http.ListenAndServe(":"+port, handler); err != nil {
		log.Fatal(err)
	}
}
