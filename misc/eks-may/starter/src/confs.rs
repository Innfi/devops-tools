use std::env;

pub struct Confs {
  pub server_binding_addr: String,
  pub db_url: String,
}

impl Confs {
  pub fn new() -> Self {
    Self {
      server_binding_addr: env::var("SERVER_ADDR")
        .expect("SERVER_ADDR not found"),
      db_url: env::var("DB_URL").expect("DB_URL not found"),
    }
  }
}
