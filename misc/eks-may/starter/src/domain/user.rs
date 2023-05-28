use actix_web::web::Data;
use chrono::{DateTime, TimeZone, Utc};
use log::{debug, error};
use serde::{Deserialize, Serialize};

use crate::persistence::DatabaseConnector;

#[derive(Serialize, Deserialize, Debug)]
pub struct EntityUser {
  pub id: i64,
  pub username: String,
  pub email: String,
  pub created_at: DateTime<Utc>,
}

#[derive(Serialize, Deserialize)]
pub struct CreateUserResult {
  pub msg: String,
}

pub struct UserService {
  db_connector: Data<DatabaseConnector>,
}

impl<'a> UserService {
  pub fn new(connector: Data<DatabaseConnector>) -> Self {
    Self {
      db_connector: connector.clone(),
    }
  }

  pub async fn find_user(
    &self,
    email: &str,
  ) -> Result<EntityUser, &'static str> {
    let select_result = sqlx::query!(
      r#"SELECT id, username, email, created_at FROM users WHERE email=?;"#,
      email,
    )
    .fetch_one(&self.db_connector.connection_pool)
    .await;

    if select_result.is_err() {
      return Err("user not found;");
    }

    let result_object = select_result.unwrap();

    debug!(
      "id: {}, created_at: {}",
      result_object.id,
      result_object.created_at.unwrap()
    );

    Ok(EntityUser {
      id: result_object.id,
      username: result_object.username.unwrap(),
      email: result_object.email.unwrap(),
      created_at: Utc.from_utc_datetime(&result_object.created_at.unwrap()),
    })
  }

  pub async fn create_user(
    &self,
    username: &str,
    email: &str,
  ) -> Result<CreateUserResult, &'static str> {
    let _ = self
      .call_create(username, email)
      .await
      .expect("create user failed");

    Ok(CreateUserResult {
      msg: format!("create success: {}", email),
    })
  }

  async fn call_create(
    &self,
    username: &str,
    email: &str,
  ) -> Result<(), &'static str> {
    let insert_result = sqlx::query!(
      r#"INSERT INTO users(username, email) VALUES (?, ?);"#,
      username,
      email,
    )
    .fetch_one(&self.db_connector.connection_pool)
    .await;

    if insert_result.is_err() {
      error!("call_create] insert failed: {}", email);
      return Err("insert failed");
    }

    Ok(())
  }
}
