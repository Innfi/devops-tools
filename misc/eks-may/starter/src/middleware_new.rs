use actix_web::Error;
use actix_web::body::MessageBody;
use actix_web::dev::{ServiceRequest, ServiceResponse};
use actix_web_lab::middleware::Next;
use log::debug;

pub async fn my_middleware(
  req: ServiceRequest,
  next: Next<impl MessageBody>,
) -> Result<ServiceResponse<impl MessageBody>, Error> {
  debug!("uri: {}", req.uri().to_string());

  let response = next.call(req).await;

  response
}