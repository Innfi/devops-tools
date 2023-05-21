use actix_web::dev::Server;
use actix_web::{web, App, HttpResponse, HttpServer};
use log::debug;
use serde::Deserialize;

use crate::domain::{EntityUser, UserService};
use crate::persistence::DatabaseConnector;

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

async fn receive_post(
  payload: web::Json<PostPayload>,
) -> web::Json<EntityUser> {
  let mut connector: DatabaseConnector = DatabaseConnector::new().await;
  let mut user_service: UserService = UserService::new(&mut connector);

  debug!("receive_post] username: {}, email: {}", payload.username, payload.email);

  let entity_user: EntityUser = user_service
    .create_user(payload.username.as_str(), payload.email.as_str())
    .await
    .expect("failed to create user");

  web::Json(entity_user)
}
