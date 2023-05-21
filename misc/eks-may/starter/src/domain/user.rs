use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::persistence::DatabaseConnector;

#[derive(Serialize, Deserialize)]
pub struct EntityUser {
  pub userid: i64,
  pub uuid: Uuid,
  pub username: String,
  pub email: String,
  pub created_at: DateTime<Utc>,
}

pub struct UserService<'a> {
  userid_counter: i64,
  db_connector: &'a mut DatabaseConnector,
}

impl<'a> UserService<'a> {
  pub fn new(connector: &'a mut DatabaseConnector) -> Self {
    Self {
      userid_counter: 0,
      db_connector: connector,
    }
  }

  pub async fn create_user(
    &mut self,
    username: &str,
    email: &str,
  ) -> Result<EntityUser, &'static str> {
    let new_userid = self.userid_counter;
    self.userid_counter += 1;

    let uuid = Uuid::new_v4();
    let _ = self.call_create(username, email, uuid).await;

    Ok(EntityUser {
      userid: new_userid,
      uuid,
      username: String::from(username),
      email: String::from(email),
      created_at: Utc::now(),
    })
  }

  async fn call_create(
    &mut self,
    username: &str,
    email: &str,
    uuid: Uuid,
  ) -> Result<(), &'static str> {
    let insert_result = sqlx::query!(
      r#"INSERT INTO users(username, email, uuid) VALUES (?, ?, ?);"#,
      username,
      email,
      uuid
    )
    .execute(&mut self.db_connector.connection)
    .await;

    let is_ok = insert_result.is_ok();
    if is_ok == true {
      return Ok(());
    }

    Err("test error")
  }
}
