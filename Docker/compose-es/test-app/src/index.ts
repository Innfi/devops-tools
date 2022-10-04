import express, { json, Request, Response } from 'express';
import winston from 'winston';
import { ElasticsearchTransport } from 'winston-elasticsearch';
import dotenv from 'dotenv';

dotenv.config();

const esUrl = process.env.ES_URL ? process.env.ES_URL :
	'http://localhost:9200';

console.log(`esUrl: ${esUrl}`);

const esTransport = new ElasticsearchTransport({
	level: 'info',
	clientOpts: { node: esUrl },
});
const logger: winston.Logger = winston.createLogger({
	transports: [esTransport],
});

const app = express();
app.use(json());

app.get('/', (req: Request, res: Response) => {
	logger.info(`GET /`);

	res.send({err: 'ok'});
});

app.post('/', (req: Request, res: Response) => {
	logger.info(`POST /: ${JSON.stringify(req.body)}`);

	res.send({ msg: req.body ? req.body : ''});
});

app.listen(3000, () => {
	console.log('start listening');
});