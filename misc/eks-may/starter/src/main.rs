use starter::startup::start_server;
use log::info;
use std::env;

#[tokio::main]
async fn main() -> std::io::Result<()> {
  env::set_var("RUST_LOG", "TRACE");

  env_logger::init();

  info!("main] server");

  let _ = start_server()?.await;

  Ok(())
}
