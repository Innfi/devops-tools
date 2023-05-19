

pub struct EntityUser {
  _userId: i64,
  pub username: String,
  pub email: String,
}

impl EntityUser {
  pub fn new(username: &str, email: &str) -> Self {
    Self {
      _userId: 1, //FIXME
      username: String::from(username),
      email: String::from(email),
    }
  }
}