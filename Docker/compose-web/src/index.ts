import express, { Request, Response } from 'express';
import mongoose, { ConnectOptions, Document, Schema } from 'mongoose';
import { createClient } from 'redis';


interface IUser extends Document {
	email: string;
	token: string;
};

const UserSchema = new Schema<IUser>({
	email: { type: String, index: true },
	token: { type: String },
});

const dbUrl = 'mongodb://mongo-server/somedb';
const userModel = mongoose.model<IUser>('sample', UserSchema);

const options: ConnectOptions = { autoCreate: true };

mongoose.connect(dbUrl, options, () => {
	console.log('connected to mongo');
});

const redisUrl = 'redis://redis-server:6379';
const client = createClient({ url: redisUrl });
client.connect().then(() => {
	console.log('redis connected');
});

const token = `dummy_token`;

const app = express();

app.post('/sample/:email', async (req: Request, res: Response) => {
	const email = req.params.email;

	await userModel.create({ email: email, token: token });
	await client.set(token, email);

	res.status(200).send({ err: 'ok'}).end();
});

app.get('/', async (req: Request, res: Response) => {
	const email = await client.get(token);

	res.status(200).send({ err: 'ok', email: email! }).end();
});

app.listen(3000);