use std::collections::HashMap;
use std::env;

use starter;

#[tokio::test]
async fn initial_e2e_works() {
  spawn_app();
  let client = reqwest::Client::new();

  let response = client
    .get("http://127.0.0.1:8000/innfi")
    .send()
    .await
    .expect("initial_e2e_works] failed to send request");

  assert!(response.status().is_success());
  assert_eq!(response.content_length().unwrap() > 0, true)
}

#[tokio::test]
async fn e2e_post_user() {
  env::set_var("RUST_LOG", "TRACE");
  spawn_app();
  let mut map = HashMap::new();
  map.insert("username", "ennfi");
  map.insert("email", "ennfi@test.io");

  let client = reqwest::Client::new();

  let response = client
    .post("http://127.0.0.1:8000/user")
    .json(&map)
    .send()
    .await
    .expect("e2e_post_user] failed to send request");

  assert!(response.status().is_success());
}

fn spawn_app() {
  let server = starter::startup::start_server().expect("failed to start_server()");

  let _ = tokio::spawn(server);
}