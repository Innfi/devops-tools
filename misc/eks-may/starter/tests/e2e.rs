use starter;

#[tokio::test]
async fn test_health_check() {
  spawn_app().await;

  let client = reqwest::Client::new();

  let response = client
    .get("http://127.0.0.1:8000/")
    .send()
    .await
    .expect("test_health_check] failed to send request");

  assert!(response.status().is_success())
}

async fn spawn_app() {
  let server =
    starter::bootstrap::run_server().expect("failed to start server");

  let _ = tokio::spawn(server);
}
