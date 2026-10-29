package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHealth(t *testing.T) {
	w := httptest.NewRecorder()
	newHandler().ServeHTTP(w, httptest.NewRequest("GET", "/health", nil))
	var got map[string]string
	if err := json.Unmarshal(w.Body.Bytes(), &got); err != nil {
		t.Fatal(err)
	}
	if w.Code != http.StatusOK || got["status"] != "ok" {
		t.Fatalf("unexpected health response: %d %s", w.Code, w.Body.String())
	}
}

func TestTickets(t *testing.T) {
	w := httptest.NewRecorder()
	newHandler().ServeHTTP(w, httptest.NewRequest("GET", "/api/tickets", nil))
	var got []Ticket
	if err := json.Unmarshal(w.Body.Bytes(), &got); err != nil {
		t.Fatal(err)
	}
	if w.Code != http.StatusOK || len(got) != 6 {
		t.Fatalf("want 6 tickets with HTTP 200, got %d: %s", w.Code, w.Body.String())
	}
	seen := map[int]bool{}
	for _, ticket := range got {
		if ticket.ID < 1 || seen[ticket.ID] || ticket.Title == "" {
			t.Fatalf("invalid or duplicate ticket: %+v", ticket)
		}
		seen[ticket.ID] = true
	}
}

func TestRoutes(t *testing.T) {
	for _, tc := range []struct {
		method, path string
		code         int
	}{
		{"GET", "/", 200},
		{"GET", "/missing", 404},
		{"GET", "/api/tickets/unknown", 404},
		{"POST", "/api/tickets", 405},
		{"POST", "/health", 405},
		{"POST", "/", 405},
	} {
		t.Run(tc.method+tc.path, func(t *testing.T) {
			w := httptest.NewRecorder()
			newHandler().ServeHTTP(w, httptest.NewRequest(tc.method, tc.path, nil))
			if w.Code != tc.code {
				t.Fatalf("want %d, got %d", tc.code, w.Code)
			}
			if tc.code == 405 && w.Header().Get("Allow") != "GET" {
				t.Fatal("missing Allow header")
			}
			if tc.path == "/" && tc.method == "GET" && !strings.Contains(w.Body.String(), "SupportDesk") {
				t.Fatal("missing page")
			}
		})
	}
}
