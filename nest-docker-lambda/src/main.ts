import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

export const initNestApp = async () => {
  return await NestFactory.create(AppModule);
};

async function bootstrap() {
  const app = await initNestApp();
  await app.listen(3000);
}
bootstrap();
