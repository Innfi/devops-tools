use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct EntityUser {
  pub userid: i64,
  pub uuid: Uuid,
  pub username: String,
  pub email: String,
}

pub struct EntityUserService {
  userid_counter: i64,
}

impl EntityUserService {
  pub fn new() -> Self {
    Self { userid_counter: 0 }
  }

  pub fn create_user(
    &mut self,
    username: &str,
    email: &str,
  ) -> Result<EntityUser, &'static str> {
    let new_userid = self.userid_counter;
    self.userid_counter += 1;

    Ok(EntityUser {
      userid: new_userid,
      uuid: Uuid::new_v4(),
      username: String::from(username),
      email: String::from(email),
    })
  }
}
