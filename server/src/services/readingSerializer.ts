import type { DailyReadingDocument } from "../models/DailyReading.js";
import type { DeepReadingDocument } from "../models/DeepReading.js";

type WithTimestamps<T> = T & {
  createdAt?: Date;
  updatedAt?: Date;
};

export function serializeDailyReading(reading: WithTimestamps<DailyReadingDocument>) {
  return {
    id: reading._id.toString(),
    localDate: reading.localDate,
    card: reading.card,
    timeContext: reading.timeContext,
    weather: reading.weather,
    markdownResult: reading.markdownResult,
    summary: reading.summary,
    resultLocale: reading.resultLocale,
    createdAt: requireDate(reading.createdAt, "createdAt").toISOString()
  };
}

export function serializeDeepReading(reading: WithTimestamps<DeepReadingDocument>) {
  return {
    id: reading._id.toString(),
    question: reading.question,
    selectedCards: reading.selectedCards,
    markdownResult: reading.markdownResult,
    summary: reading.summary,
    resultLocale: reading.resultLocale,
    isSavedForHistory: reading.isSavedForHistory,
    createdAt: requireDate(reading.createdAt, "createdAt").toISOString()
  };
}

export function serializeDeepReadingHistory(reading: WithTimestamps<DeepReadingDocument>) {
  return {
    id: reading._id.toString(),
    question: reading.question,
    summary: reading.summary,
    resultLocale: reading.resultLocale,
    createdAt: requireDate(reading.createdAt, "createdAt").toISOString()
  };
}

function requireDate(value: Date | undefined, fieldName: string) {
  if (!value) {
    throw new Error(`Reading document missing ${fieldName}`);
  }

  return value;
}
