FROM node as builder
WORKDIR /usr/src/app
COPY [ "package.json", "package-lock.json", "./" ]
RUN [ "npm", "install" ]
COPY [ "src/", "./src/" ]

FROM node:alpine
LABEL name=min-start
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app ./
ENTRYPOINT [ "node", "./src/index.js" ]
EXPOSE 8080