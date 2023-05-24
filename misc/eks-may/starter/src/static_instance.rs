use async_once_cell::OnceCell;

use crate::domain::UserService;

#[derive(Debug)]
pub struct GlobalInstance {}

static INSTANCE: OnceCell<GlobalInstance> = OnceCell::new_with(Some(UserService {
  db_connector: todo!()
}));