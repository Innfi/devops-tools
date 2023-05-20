use actix_web::dev::Server;
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use log::debug;
use serde::Deserialize;

#[derive(Deserialize)]
struct PostPayload {
  username: String,
  email: String,
}

pub fn run_server() -> Result<Server, std::io::Error> {
  let server = HttpServer::new(move || {
    App::new()
      .route("/", web::get().to(health_check))
      .route("/receive_post", web::post().to(receive_post))
  })
  .bind("127.0.0.1:8000")?
  .run();

  Ok(server)
}

async fn health_check() -> HttpResponse {
  debug!("health_check");
  HttpResponse::Ok().finish()
}

async fn receive_post(payload: web::Json<PostPayload>) -> impl Responder {
  format!("username: {}, email: {}", payload.username, payload.email);

  HttpResponse::Ok().finish()
}
