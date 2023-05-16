use sqlx::{Connection, MySqlConnection};

pub struct DatabaseConnector {
  connection: MysqlConnection,
}

impl DatabaseConnector {
  pub fn init() {
    toto!();
  }
}