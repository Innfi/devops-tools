use std::env;

pub struct Confs {
  pub server_binding_addr: String,
  pub db_url: String,
}

impl Confs {
  pub fn new() -> Self {
    Self {
      server_binding_addr: env::var("SERVER_ADDR").unwrap_or(
        String::from("127.0.0.1:8000")
      ),
      db_url: env::var("DB_URL").unwrap_or(
        String::from("mysql://innfislocal:test1234@localhost:3306/innfi")
      ),
    }
  }
}
