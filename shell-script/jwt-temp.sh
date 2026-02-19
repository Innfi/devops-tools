#!/bin/bash
HEADER=$(echo -n '{"alg":"HS256","typ":"JWT"}' | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
PAYLOAD=$(echo -n '{"sub":"1234","iat":1516239022}' | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
SIG=$(echo -n "${HEADER}.${PAYLOAD}" | openssl dgst -sha256 -hmac "mysecret" -binary | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
echo "${HEADER}.${PAYLOAD}.${SIG}"
