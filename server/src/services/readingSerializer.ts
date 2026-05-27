import type { DailyReadingDocument } from "../models/DailyReading.js";
import type { DeepReadingDocument } from "../models/DeepReading.js";
import { resolveTaiwanRegionName } from "./weatherService.js";

type WithTimestamps<T> = T & {
  createdAt?: Date;
  updatedAt?: Date;
};

export function serializeDailyReading(
  reading: WithTimestamps<DailyReadingDocument>,
  options: { dailyStreak?: number } = {}
) {
  return {
    id: reading._id.toString(),
    localDate: reading.localDate,
    card: reading.card,
    timeContext: reading.timeContext,
    weather: serializeWeatherSnapshot(reading.weather, reading.resultLocale),
    dailyStreak: options.dailyStreak ?? 0,
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

function serializeWeatherSnapshot(
  weather: DailyReadingDocument["weather"],
  locale: DailyReadingDocument["resultLocale"]
) {
  if (
    weather.locationName ||
    typeof weather.latitude !== "number" ||
    typeof weather.longitude !== "number"
  ) {
    return weather;
  }

  return {
    ...weather,
    locationName: resolveTaiwanRegionName(weather.latitude, weather.longitude, locale)
  };
}
