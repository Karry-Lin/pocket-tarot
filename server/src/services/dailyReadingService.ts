import { ApiError } from "../http/apiError.js";
import { DailyReadingModel } from "../models/DailyReading.js";
import type { UserDocument } from "../models/User.js";
import type { AppDependencies } from "../types/appDependencies.js";
import { drawCards, getCardForPrompt } from "./cardDrawService.js";
import { cleanReadingMarkdown, fallbackSummary } from "./markdownService.js";
import { getTaipeiTimeContext } from "./timeContextService.js";
import { parseLocale } from "./localeService.js";

type CreateDailyReadingInput = {
  locale?: unknown;
  weather?: unknown;
};

export async function getTodayDailyReading(user: UserDocument) {
  const timeContext = getTaipeiTimeContext();
  const reading = await DailyReadingModel.findOne({
    userId: user._id,
    localDate: timeContext.localDate
  });

  if (!reading) {
    throw new ApiError(404, "DAILY_READING_NOT_FOUND", "今日尚未抽牌");
  }

  return reading;
}

export async function getDailyReadingStreak(user: UserDocument) {
  const today = getTaipeiTimeContext().localDate;
  const readings = await DailyReadingModel.find({
    userId: user._id,
    localDate: { $lte: today }
  })
    .select("localDate")
    .sort({ localDate: -1 })
    .lean();
  const dates = new Set(readings.map((reading) => reading.localDate));
  let expectedDate = parseLocalDate(today);
  let streak = 0;

  while (dates.has(formatLocalDate(expectedDate))) {
    streak += 1;
    expectedDate = addDays(expectedDate, -1);
  }

  return streak;
}

export async function createTodayDailyReading(
  user: UserDocument,
  input: CreateDailyReadingInput,
  dependencies: AppDependencies
) {
  const locale = parseLocale(input.locale);
  const timeContext = getTaipeiTimeContext();
  const existing = await DailyReadingModel.findOne({
    userId: user._id,
    localDate: timeContext.localDate
  });

  if (existing) {
    return {
      reading: existing,
      created: false
    };
  }

  const weather = await dependencies.weatherService.resolveWeather(
    typeof input.weather === "object" && input.weather !== null ? input.weather : {}
  );
  const card = drawCards(1)[0];
  const markdownResult = cleanReadingMarkdown(
    await dependencies.llmService.generateDailyReading({
      locale,
      card: getCardForPrompt(card),
      timeContext,
      weather
    })
  );
  const summary = await generateSummaryWithFallback(dependencies, locale, "daily", markdownResult, 40);

  try {
    const reading = await DailyReadingModel.create({
      userId: user._id,
      localDate: timeContext.localDate,
      card,
      timeContext,
      weather,
      markdownResult,
      summary,
      resultLocale: locale
    });

    return {
      reading,
      created: true
    };
  } catch (error) {
    if (isDuplicateKey(error)) {
      const duplicated = await DailyReadingModel.findOne({
        userId: user._id,
        localDate: timeContext.localDate
      });

      if (duplicated) {
        return {
          reading: duplicated,
          created: false
        };
      }
    }

    throw error;
  }
}

export async function generateSummaryWithFallback(
  dependencies: AppDependencies,
  locale: "zh-TW" | "en",
  readingType: "daily" | "deep",
  markdownResult: string,
  fallbackLength: number
) {
  try {
    const summary = await dependencies.llmService.generateSummary({
      locale,
      readingType,
      markdownResult
    });

    return summary.trim() || fallbackSummary(markdownResult, fallbackLength);
  } catch (error) {
    console.error(error);
    return fallbackSummary(markdownResult, fallbackLength);
  }
}

function isDuplicateKey(error: unknown) {
  return typeof error === "object" && error !== null && "code" in error && error.code === 11000;
}

function parseLocalDate(value: string) {
  const [year, month, day] = value.split("-").map((part) => Number(part));
  return new Date(Date.UTC(year, month - 1, day));
}

function addDays(value: Date, days: number) {
  const next = new Date(value);
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}

function formatLocalDate(value: Date) {
  const year = value.getUTCFullYear();
  const month = String(value.getUTCMonth() + 1).padStart(2, "0");
  const day = String(value.getUTCDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}
