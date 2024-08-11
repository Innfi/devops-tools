FROM public.ecr.aws/lambda/nodejs:20 as build

WORKDIR /usr/src/app

COPY package*.json tsconfig.json .
RUN npm install --global yarn 
RUN yarn install
RUN yarn clean

COPY ./src ./src
RUN yarn build


FROM public.ecr.aws/lambda/nodejs:20

COPY --from=build /usr/src/app/dist .

CMD ["dist/lambda.handler"]
