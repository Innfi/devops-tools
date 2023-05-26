use actix_web::dev::Server;
use actix_web::{
  get, post, Data,
  error, web, App, Error, HttpRequest, HttpResponse, HttpServer,
};
use log::debug;
use serde::Deserialize;

use crate::domain::{CreateUserResult, EntityUser, UserService};
use crate::persistence::DatabaseConnector;

#[derive(Deserialize)]
struct UserPayload {
  username: String,
  email: String,
}

pub async fn run_server() -> Result<Server, std::io::Error> {
  let connector: DatabaseConnector = DatabaseConnector::new().await;
  let connector_data = web::Data::new(connector);
  let user_service: UserService = UserService::new(connector_data);
  let data = web::Data::new(user_service);
  

  let server = HttpServer::new(move || {
    App::new()
      .route("/", web::get().to(health_check))
      .service(create_user)
      .service(find_user)
      .app_data(data.clone())
  })
  .bind("127.0.0.1:8000")?
  .run();

  Ok(server)
}

async fn health_check() -> HttpResponse {
  debug!("health_check");
  HttpResponse::Ok().finish()
}

#[post("/user")]
async fn create_user(
  payload: web::Json<UserPayload>,
) -> web::Json<CreateUserResult> {
  let mut connector: DatabaseConnector = DatabaseConnector::new().await;
  let mut user_service: UserService = UserService::new(&mut connector);

  debug!(
    "create_user] username: {}, email: {}",
    payload.username, payload.email
  );

  let result = user_service
    .create_user(payload.username.as_str(), payload.email.as_str())
    .await
    .expect("failed to create user");

  web::Json(result)
}

#[get("/user/{email}")]
async fn find_user(req: HttpRequest) -> Result<HttpResponse, Error> {
  let email = req.match_info().get("email").expect("email not found");

  let mut connector: DatabaseConnector = DatabaseConnector::new().await;
  let mut user_service: UserService = UserService::new(&mut connector);

  let find_result: Result<EntityUser, &'static str> =
    user_service.find_user(email).await;

  if find_result.is_err() {
    return Err(error::ErrorNotFound("not found"));
  }

  Ok(HttpResponse::Ok().json(find_result.unwrap()))
}
