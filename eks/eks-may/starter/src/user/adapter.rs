use actix_web::web;
use chrono::{TimeZone, Utc};
use log::{debug, error};
use sqlx::MySqlPool;

use crate::confs::Confs;
use crate::user::entity::UserPayload;
use crate::user::EntityUser;

pub struct UserDatabaseAdapter {
  pub connection_pool: MySqlPool,
}

impl UserDatabaseAdapter {
  pub async fn new(confs: &Confs) -> Self {
    Self {
      connection_pool: MySqlPool::connect(&confs.db_url)
        .await
        .expect("failed to connect to database"),
    }
  }

  pub async fn insert_user(
    &self,
    payload: &web::Json<UserPayload>,
  ) -> Result<i32, &'static str> {
    let insert_result = sqlx::query!(
      r#"INSERT INTO users(username, email) VALUES (?, ?);"#,
      payload.username.as_str(),
      payload.email.as_str(),
    )
    .execute(&self.connection_pool)
    .await;

    if insert_result.is_err() {
      error!("call_create] insert failed: {}", payload.email);
      return Err("insert failed");
    }

    Ok(1)
  }

  pub async fn select_user(
    &self,
    email: &str,
  ) -> Result<EntityUser, &'static str> {
    let select_result = sqlx::query!(
      r#"SELECT id, username, email, created_at FROM users WHERE email=?;"#,
      email,
    )
    .fetch_one(&self.connection_pool)
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
}
