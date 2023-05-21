// #[cfg(test)]
// mod test_user_service {
//   use starter::domain::{EntityUser, EntityUserService};
//   use std::collections::HashSet;
//   use uuid::Uuid;
//
//   #[test]
//   fn create_user_input_field() {
//     let mut service = EntityUserService::new();
//
//     let create_result = service.create_user("innfi", "innfi@test.com");
//     assert_eq!(create_result.is_ok(), true);
//
//     let new_user: EntityUser = create_result.unwrap();
//     assert_eq!(new_user.username.as_str(), "innfi");
//     assert_eq!(new_user.email, "innfi@test.com");
//   }
//
//   #[test]
//   fn create_user_unique_id() {
//     let mut service = EntityUserService::new();
//
//     let count = 10;
//     let mut userid_set: HashSet<i64> = HashSet::new();
//     let mut uuid_set: HashSet<Uuid> = HashSet::new();
//
//     for _ in 0..count {
//       let result = service.create_user("innfi", "innfi@test.com");
//
//       assert_eq!(result.is_ok(), true);
//
//       let new_user: EntityUser = result.unwrap();
//       assert_eq!(userid_set.contains(&new_user.userid), false);
//       assert_eq!(uuid_set.contains(&new_user.uuid), false);
//
//       userid_set.insert(new_user.userid);
//       uuid_set.insert(new_user.uuid);
//     }
//   }
// }
//
