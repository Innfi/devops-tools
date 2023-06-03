use actix_web::web::{self, Data};
use log::debug;
use serde::{Deserialize, Serialize};

use crate::user::entity::{EntityUser, UserPayload};
use crate::user::UserDatabaseAdapter;

#[derive(Serialize, Deserialize)]
pub struct CreateUserResult {
  pub msg: String,
}

pub struct UserService {
  user_adapter: Data<UserDatabaseAdapter>,
}

impl UserService {
  pub fn new(adapter: Data<UserDatabaseAdapter>) -> Self {
    Self {
      user_adapter: adapter.clone(),
    }
  }

  pub async fn find_user(
    &self,
    email: &str,
  ) -> Result<EntityUser, &'static str> {
    debug!("find_user] email: {}", email);

    return self.user_adapter.select_user(email).await;
  }

  pub async fn create_user(
    &self,
    payload: &web::Json<UserPayload>,
  ) -> Result<CreateUserResult, &'static str> {
    debug!("create_user] email: {}", payload.email);

    let insert_result = self.user_adapter.insert_user(payload).await;
    if insert_result.is_err() {
      return Err("create_user] create failed");
    }

    Ok(CreateUserResult {
      msg: format!("create success: {}", payload.email),
    })
  }
}
