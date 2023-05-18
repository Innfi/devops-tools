use std::env;
use sqlx::{Connection, MySqlConnection};

pub struct DatabaseConnector {
  pub connection: MySqlConnection,
}

impl DatabaseConnector {
  pub async fn new() -> Self {
    let db_url = env::var("DB_URL").expect("env not found");

    Self {
      connection: MySqlConnection::connect(&db_url).await
        .expect("failed to connect to database")
    }
  }
}