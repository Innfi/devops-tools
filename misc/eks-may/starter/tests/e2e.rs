use std::collections::HashMap;
use std::env;
use sqlx::{Connection, MySqlConnection};

use starter;

#[tokio::test]
async fn initial_e2e_works() {
  let connection = MySqlConnection::connect(&"mysql://127.0.0.1:3306/innfi")
    .await.expect("failed to connect to database");
  spawn_app(connection);
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
  let connection = MySqlConnection::connect(&"mysql://127.0.0.1:3306/innfi")
    .await.expect("failed to connect to database");
  spawn_app(connection);
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

fn spawn_app(connection: MySqlConnection) {
  let server = starter::startup::start_server(connection).expect("failed to start_server()");

  let _ = tokio::spawn(server);
}