FROM node:12
WORKDIR /usr/src/app
COPY ./ ./
RUN npm install && npm run build
CMD [ "node", "src/index.js" ]
EXPOSE 3000