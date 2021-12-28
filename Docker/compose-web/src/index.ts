import express, { Request, Response } from 'express';

const app = express();

app.get('/', (req: Request, res: Response) => {
	res.status(200).send({ err: 'ok' }).end();
});

app.listen(3000);