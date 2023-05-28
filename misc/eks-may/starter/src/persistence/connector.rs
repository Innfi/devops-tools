use sqlx::MySqlPool;
use std::env;

pub struct DatabaseConnector {
  pub connection_pool: MySqlPool,
}

impl DatabaseConnector {
  pub async fn new() -> Self {
    let db_url = env::var("DB_URL").expect("env not found");

    Self {
      connection_pool: MySqlPool::connect(&db_url)
        .await
        .expect("failed to connect to database"),
    }
  }
}
