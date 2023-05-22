use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use log::debug;

use crate::persistence::DatabaseConnector;

#[derive(Serialize, Deserialize)]
pub struct EntityUser {
  pub id: i64,
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

  pub async fn find_user(&mut self, email: &str) -> Result<EntityUser, &'static str> {
    let entity_user = sqlx::query!(
      r#"SELECT id, uuid, username, email, created_at FROM users WHERE email=?;"#,
      email,
    )
    .fetch_one(&mut self.db_connector.connection)
    .await
    .expect("failed to select user");

    debug!("id: {}, created_at: {}", entity_user.id, entity_user.created_at.unwrap());

    Err("test")
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
      id: new_userid,
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
    debug!("username: {}, email: {}, uuid: {}", username, email, uuid.to_string());
    let insert_result = sqlx::query!(
      r#"INSERT INTO users(username, email, uuid) VALUES (?, ?, ?);"#,
      username,
      email,
      "test_uuid"
    )
    .execute(&mut self.db_connector.connection)
    .await
    .expect("failed to insert into users");
    debug!("call_create] ------------------------------ ");

    debug!("insert id: {}", insert_result.last_insert_id());

    Ok(())
  }
}
