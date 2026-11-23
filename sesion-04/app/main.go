package main

import (
	_ "embed"
	"encoding/json"
	"log"
	"net"
	"net/http"
	"os"
	"time"
)

//go:embed index.html
var page []byte

type Ticket struct {
	ID       int    `json:"id"`
	Title    string `json:"title"`
	Status   string `json:"status"`
	Priority string `json:"priority"`
}

// Datos ficticios de solo lectura. No hay base de datos en este primer lab.
var tickets = []Ticket{
	{1, "VPN no conecta desde la oficina", "open", "high"},
	{2, "Disco del servidor de pruebas al 90%", "in_progress", "high"},
	{3, "Solicitud de acceso al repositorio", "open", "medium"},
	{4, "Renovación de certificado completada", "closed", "low"},
	{5, "Latencia elevada en API de inventario", "in_progress", "medium"},
	{6, "Restauración de backup verificada", "closed", "low"},
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(value); err != nil {
		log.Printf("response encoding failed: %v", err)
	}
}

func newHandler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			writeJSON(w, http.StatusNotFound, map[string]string{"error": "not found"})
			return
		}
		if r.Method != http.MethodGet {
			w.Header().Set("Allow", "GET")
			writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		_, _ = w.Write(page)
	})
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.Header().Set("Allow", "GET")
			writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
			return
		}
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok", "service": "supportdesk"})
	})
	mux.HandleFunc("/api/tickets", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.Header().Set("Allow", "GET")
			writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
			return
		}
		// Ejercicio de la sesión: agregar filtro opcional por status.
		writeJSON(w, http.StatusOK, tickets)
	})
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		mux.ServeHTTP(w, r)
		log.Printf("method=%s path=%s duration=%s", r.Method, r.URL.Path, time.Since(start))
	})
}

func main() {
	host := os.Getenv("HOST")
	if host == "" {
		host = "127.0.0.1"
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	server := &http.Server{
		Addr:              net.JoinHostPort(host, port),
		Handler:           newHandler(),
		ReadHeaderTimeout: 5 * time.Second,
		WriteTimeout:      10 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
	log.Printf("SupportDesk listening at http://%s", server.Addr)
	log.Fatal(server.ListenAndServe())
}
