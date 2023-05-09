use actix_web::dev::Server;
use actix_web::{web, App, HttpRequest, HttpServer, Responder, HttpResponse};
use serde::Deserialize;

#[derive(Deserialize)]
struct PostPayload {
  username: String,
  email: String,
}

async fn test_post(payload: web::Json<PostPayload>) -> impl Responder {
  format!("username: {}, email: {}", payload.username, payload.email)
}

async fn greet(req: HttpRequest) -> impl Responder {
  let name = req.match_info().get("name").unwrap_or("world");

  format!("hello {}!", &name)
}

async fn health_check() -> HttpResponse {
  HttpResponse::Ok().finish()
}

pub fn start_server() -> Result<Server, std::io::Error> {
  let server = HttpServer::new(|| {
    App::new()
      .route("/health_check", web::get().to(health_check))
      .route("/", web::get().to(greet))
      .route("/{name}", web::get().to(greet))
      .route("/user", web::post().to(test_post))
  })
  .bind("127.0.0.1:8000")?
  .run();

  Ok(server) 
}