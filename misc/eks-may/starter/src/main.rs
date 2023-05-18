use log::info;
use std::env;
use starter::startup::start_server;
use starter::persistence::DatabaseConnector;

#[tokio::main]
async fn main() -> std::io::Result<()> {
  env::set_var("RUST_LOG", "TRACE");

  env_logger::init();

  info!("main] server");

  let connector = DatabaseConnector::new().await;
  let _ = start_server(connector)?.await;

  Ok(())
}
