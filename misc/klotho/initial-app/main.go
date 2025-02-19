package main

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	router := chi.NewRouter()
	router.Use(middleware.Logger)

	router.Get("/hello", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("hello from klotho"))
	})

	router.Get("/hello/{name}", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(fmt.Sprintf("hello, %s\n", chi.URLParam(r, "name"))))
	})

	fmt.Println("listening on 3000")

	/*
		  @klotho::expose {
				target = "public"
				id = "app"
			}
	*/
	http.ListenAndServe(":3000", router)
}
