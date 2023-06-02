use actix_web::web;
use log::info;
use starter::persistence::DatabaseConnector;
use std::env;

use starter::bootstrap::run_server;
use starter::confs::Confs;
use starter::user::UserService;
use starter::user::UserDatabaseAdapter;

#[tokio::main]
async fn main() -> std::io::Result<()> {
  init_logger();

  info!("main] server");

  let confs = Confs::new();

  let user_service = create_user_service_data(&confs).await;
  let _ = run_server(&confs, user_service)?.await;

  Ok(())
}

fn init_logger() {
  env::set_var("RUST_LOG", "TRACE");

  env_logger::init();
}

async fn create_user_service_data(confs: &Confs) -> web::Data<UserService> {
  let user_adapter = web::Data::new(DatabaseConnector::new(confs).await);

  return web::Data::new(UserService::new(user_adapter));
}
