use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

#[derive(Serialize, Deserialize, Debug)]
pub struct EntityUser {
  pub id: i64,
  pub username: String,
  pub email: String,
  pub created_at: DateTime<Utc>,
}

#[derive(Deserialize)]
pub struct UserPayload {
  pub username: String,
  pub email: String,
}
