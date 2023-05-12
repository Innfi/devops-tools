use actix_web::dev::Server;
use actix_web::{web, App, HttpRequest, HttpServer, Responder, HttpResponse};
use serde::Deserialize;
use log::{debug, error};

#[derive(Deserialize)]
struct PostPayload {
  username: String,
  email: String,
}

async fn post_user(payload: web::Json<PostPayload>) -> impl Responder {
  format!("username: {}, email: {}", payload.username, payload.email)
}

async fn greet(req: HttpRequest) -> impl Responder {
  let name = req.match_info().get("name").unwrap_or("world");
  error!("greet] test error msg: {}", name);

  format!("hello {}!", &name)
}

async fn health_check() -> HttpResponse {
  debug!("health_check");
  HttpResponse::Ok().finish()
}

pub fn start_server() -> Result<Server, std::io::Error> {
  let server = HttpServer::new(|| {
    App::new()
      .route("/health_check", web::get().to(health_check))
      .route("/", web::get().to(greet))
      .route("/{name}", web::get().to(greet))
      .route("/user", web::post().to(post_user))
  })
  .bind("127.0.0.1:8000")?
  .run();

  Ok(server) 
}