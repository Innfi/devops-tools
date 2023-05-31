use actix_web::dev::Server;
use actix_web::{
  error, get, post, web, App, Error, HttpRequest, HttpResponse, HttpServer,
};
use log::debug;

use crate::user::{CreateUserResult, EntityUser, UserPayload, UserService};

pub fn run_server(
  user_service: web::Data<UserService>,
) -> Result<Server, std::io::Error> {
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
    .create_user(&payload)
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
