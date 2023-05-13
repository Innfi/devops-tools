use starter::startup::start_server;
use log::info;
use std::env;
use sqlx::{Connection, MySqlConnection};

#[tokio::main]
async fn main() -> std::io::Result<()> {
  env::set_var("RUST_LOG", "TRACE");

  env_logger::init();

  info!("main] server");

  let connection = MySqlConnection::connect(&"mysql://127.0.0.1:3306/innfi")
    .await.expect("failed to connect to database");

  let _ = start_server(connection)?.await;

  Ok(())
}
