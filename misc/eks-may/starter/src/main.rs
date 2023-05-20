use log::info;
use starter::bootstrap::run_server;
use std::env;

#[tokio::main]
async fn main() -> std::io::Result<()> {
  env::set_var("RUST_LOG", "TRACE");

  env_logger::init();

  info!("main] server");

  let _ = run_server()?.await;

  Ok(())
}
