use actix_web::web;
use log::info;
use std::env;

use starter::bootstrap::run_server;
use starter::confs::Confs;
use starter::user::UserDatabaseAdapter;
use starter::user::UserService;
use starter::side_runner::runner;

#[tokio::main]
async fn main() -> std::io::Result<()> {
  init_logger();

  info!("main] server");

  let confs = Confs::new();

  let _ = tokio::spawn(async {
    runner().await
  });

  let user_service = create_user_service_data(&confs).await;
  let _ = run_server(&confs, user_service)?.await;

  Ok(())
}

fn init_logger() {
  env::set_var("RUST_LOG", "TRACE");

  env_logger::init();
}

async fn create_user_service_data(confs: &Confs) -> web::Data<UserService> {
  let user_adapter = web::Data::new(UserDatabaseAdapter::new(confs).await);

  return web::Data::new(UserService::new(user_adapter));
}
