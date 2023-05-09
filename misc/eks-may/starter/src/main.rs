use starter::startup::start_server;

#[tokio::main]
async fn main() -> std::io::Result<()> {
  let _ = start_server()?;

  Ok(())
}
