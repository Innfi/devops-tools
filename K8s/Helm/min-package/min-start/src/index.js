import express from 'express';

const app = express();

app.get('/', (req, res) => {
  res.status(200).send({ err: 'ok' });
});

app.listen(8080, () => { });