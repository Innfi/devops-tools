use actix_web::dev::Server;
use actix_web::{web, App, HttpResponse, HttpServer, HttpRequest};
use log::debug;
use serde::Deserialize;

use crate::domain::{EntityUser, UserService};
use crate::persistence::DatabaseConnector;

#[derive(Deserialize)]
struct UserPayload {
  username: String,
  email: String,
}

pub fn run_server() -> Result<Server, std::io::Error> {
  let server = HttpServer::new(move || {
    App::new()
      .route("/", web::get().to(health_check))
      .route("/user", web::post().to(create_user))
      .route("/user/{email}", web::get().to(find_user))
  })
  .bind("127.0.0.1:8000")?
  .run();

  Ok(server)
}

async fn health_check() -> HttpResponse {
  debug!("health_check");
  HttpResponse::Ok().finish()
}

async fn create_user(
  payload: web::Json<UserPayload>,
) -> web::Json<EntityUser> {
  let mut connector: DatabaseConnector = DatabaseConnector::new().await;
  let mut user_service: UserService = UserService::new(&mut connector);

  debug!("create_user] username: {}, email: {}", payload.username, payload.email);

  let entity_user: EntityUser = user_service
    .create_user(payload.username.as_str(), payload.email.as_str())
    .await
    .expect("failed to create user");

  web::Json(entity_user)
}

async fn find_user(req: HttpRequest) -> web::Json<EntityUser> {
  let email = req.match_info().get("email").expect("email not found");

  let mut connector: DatabaseConnector = DatabaseConnector::new().await;
  let mut user_service: UserService = UserService::new(&mut connector);

  debug!("find_user] email: {}", email);

  let user: EntityUser = user_service.find_user(email)
    .await.expect("failed to find user");
    
  web::Json(user)
}