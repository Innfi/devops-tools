use actix_web::web;
use starter::{self, confs::Confs};
use starter::user::{UserDatabaseAdapter, UserService, EntityUser};

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

#[tokio::test]
async fn test_get_user() {
  spawn_app().await;
  let client = reqwest::Client::new();
  
  let response = client
    .get("http://127.0.0.1:8000/user/pasta@test.com")
    .send()
    .await
    .expect("test_get_user] failed to get user");

  print!("response len: {}", response.content_length().unwrap());

  let entity_user: EntityUser = response.json::<EntityUser>().await.unwrap();

  assert_eq!(entity_user.email.eq("pasta@test.com"), true);
}

async fn spawn_app() {
  let confs = Confs::new();
  let user_adapter = web::Data::new(UserDatabaseAdapter::new(&confs).await);

  let server = starter::bootstrap::run_server(&confs, 
    web::Data::new(UserService::new(user_adapter))
  ).expect("failed to start server");
    // .await
    // .expect("failed to start server");

  let _ = tokio::spawn(server);
}
