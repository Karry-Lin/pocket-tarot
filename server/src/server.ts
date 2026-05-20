import "dotenv/config";

import { createApp } from "./app.js";
import { connectToMongo } from "./db/mongo.js";

const port = Number(process.env.PORT ?? 4000);
const mongoUri = process.env.MONGODB_URI;

if (!mongoUri) {
  throw new Error("MONGODB_URI is required");
}

await connectToMongo(mongoUri);

const app = createApp();

app.listen(port, () => {
  console.log(`Pocket Tarot API listening on port ${port}`);
});
