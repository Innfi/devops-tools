use std::{thread, time};
use log::debug;

pub async fn runner() -> Result<(), &'static str> {
  let mut counter = 0;
  loop {
    debug!("runner] called");

    thread::sleep(time::Duration::from_millis(1000));

    counter += 1;
    if counter > 10000 {
      break;
    }
  } 

  Ok(())
}