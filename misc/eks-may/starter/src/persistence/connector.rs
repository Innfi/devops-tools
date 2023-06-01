use sqlx::MySqlPool;

use crate::confs::Confs;

pub struct DatabaseConnector {
  pub connection_pool: MySqlPool,
}

impl DatabaseConnector {
  pub async fn new(confs: &Confs) -> Self {
    Self {
      connection_pool: MySqlPool::connect(&confs.db_url)
        .await
        .expect("failed to connect to database"),
    }
  }
}
