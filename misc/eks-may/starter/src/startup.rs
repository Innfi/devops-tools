use actix_web::dev::Server;
use actix_web::{web, App, HttpRequest, HttpServer, Responder, HttpResponse};
use serde::Deserialize;
use log::{debug, error};
use sqlx::MySqlConnection;
use chrono::Utc;
use uuid::Uuid;
use crate::persistence::DatabaseConnector;

#[derive(Deserialize)]
struct PostPayload {
  username: String,
  email: String,
}

async fn post_user(
  payload: web::Json<PostPayload>,
  connection: web::Data<MySqlConnection>,
) -> impl Responder {
  format!("username: {}, email: {}", payload.username, payload.email);
  sqlx::query!(
    r#"
    INSERT INTO users(id, username, email, createdAt) 
    VALUES ($1, $2, $3, $4)
    "#,
    Uuid::new_v4(),
    payload.username,
    payload.email,
    Utc::new()
  )
  .execute(connection.get_ref())
  .await;

  HttpResponse::Ok().finish()
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

pub fn start_server(
  connector: DatabaseConnector,
) -> Result<Server, std::io::Error> {
  let connection = web::Data::new(connector.connection);

  let server = HttpServer::new(move || {
    App::new()
      .route("/health_check", web::get().to(health_check))
      .route("/", web::get().to(greet))
      .route("/{name}", web::get().to(greet))
      .route("/user", web::post().to(post_user))
      .app_data(connection.clone())
  })
  .bind("127.0.0.1:8000")?
  .run();

  Ok(server) 
}