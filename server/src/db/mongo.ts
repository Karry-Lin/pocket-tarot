import mongoose from "mongoose";

export async function connectToMongo(uri: string): Promise<typeof mongoose> {
  return mongoose.connect(uri);
}

export async function disconnectFromMongo(): Promise<void> {
  await mongoose.disconnect();
}
