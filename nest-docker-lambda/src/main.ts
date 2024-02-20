import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

export const initNestApp = async () => {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api');

  return app;
};

async function bootstrap() {
  const app = await initNestApp();
  await app.listen(3000);
}
bootstrap();
