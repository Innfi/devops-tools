use actix_web::dev::Server;
use actix_web::{
  error, get, post, web, App, Error, HttpRequest, HttpResponse, HttpServer,
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
  let user_service = create_user_service_data().await;

  let server = HttpServer::new(move || {
    App::new()
      .route("/", web::get().to(health_check))
      .service(create_user)
      .service(find_user)
      .app_data(user_service.clone())
  })
  .bind("127.0.0.1:8000")?
  .run();

  Ok(server)
}

async fn create_user_service_data() -> web::Data<UserService> {
  let connector_data = web::Data::new(DatabaseConnector::new().await);

  return web::Data::new(UserService::new(connector_data));
}

async fn health_check() -> HttpResponse {
  debug!("health_check");
  HttpResponse::Ok().finish()
}

#[post("/user")]
async fn create_user(
  user_service: web::Data<UserService>,
  payload: web::Json<UserPayload>,
) -> web::Json<CreateUserResult> {
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
async fn find_user(
  data_service: web::Data<UserService>,
  req: HttpRequest,
) -> Result<HttpResponse, Error> {
  let email = req.match_info().get("email").expect("email not found");

  let find_result: Result<EntityUser, &'static str> =
    data_service.find_user(email).await;

  if find_result.is_err() {
    return Err(error::ErrorNotFound("not found"));
  }

  Ok(HttpResponse::Ok().json(find_result.unwrap()))
}
