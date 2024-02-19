import { configure } from '@vendia/serverless-express';
import { Callback, Context, Handler } from 'aws-lambda';

import { initNestApp } from './main';

let server: Handler;

const getApp = async (): Promise<any> => {
  const app = await initNestApp();
  await app.init();

  const instance = app.getHttpAdapter().getInstance();
  return configure({
    app: instance,
  });
};

export const handler: Handler = async (
  event: any,
  context: Context,
  callback: Callback,
) => {
  server = server ?? (await getApp());

  return server(event, context, callback);
};