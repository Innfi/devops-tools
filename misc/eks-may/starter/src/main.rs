use actix_web::web;
use log::info;
use std::env;

use starter::{
  bootstrap::run_server, user::UserService, persistence::DatabaseConnector,
};

#[tokio::main]
async fn main() -> std::io::Result<()> {
  env::set_var("RUST_LOG", "TRACE");

  env_logger::init();

  info!("main] server");

  let user_service = create_user_service_data().await;
  let _ = run_server(user_service)?.await;

  Ok(())
}

async fn create_user_service_data() -> web::Data<UserService> {
  let connector_data = web::Data::new(DatabaseConnector::new().await);

  return web::Data::new(UserService::new(connector_data));
}
