#[cfg(test)]
mod test_user_service {
  use actix_web::web;
  use starter::user::{UserService, UserDatabaseAdapter, UserPayload, EntityUser};
  use starter::confs::Confs;

  #[tokio::test]
  async fn create_user_input_field() {
    let service = create_user_service().await;

    let payload = web::Json(UserPayload {
      username: String::from("innfi"),
      email: String::from("innfi@test.com")
    });
    let create_result = service.create_user(&payload).await;
    assert_eq!(create_result.is_ok(), true);

    let unwrapped = create_result.unwrap();
    assert_eq!(unwrapped.msg, format!("create success: {}", payload.email));
  }

  #[tokio::test]
  async fn select_user() {
    let service = create_user_service().await;

    let find_result = service.find_user(&"innfi@test.com").await;
    assert_eq!(find_result.is_ok(), true);

    let unwrapped: EntityUser = find_result.unwrap();
    assert_eq!(unwrapped.username.as_str(), "innfi");
    assert_eq!(unwrapped.email.as_str(), "innfi@test.com");
  }

  async fn create_user_service() -> UserService {
    let confs = Confs::new();
    let user_adapter = web::Data::new(UserDatabaseAdapter::new(&confs).await);
    UserService::new(user_adapter)
  }
}

