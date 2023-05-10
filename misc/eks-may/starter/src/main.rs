use starter::startup::start_server;
use log::info;

#[tokio::main]
async fn main() -> std::io::Result<()> {
  env_logger::init();

  info!("starter::main] start server");

  let _ = start_server()?.await;

  Ok(())
}
