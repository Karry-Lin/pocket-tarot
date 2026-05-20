import mongoose from "mongoose";

import { tarotCards, isValidCardId, type Orientation } from "../data/tarotCards.js";
import { ApiError } from "../http/apiError.js";
import { DeepReadingModel, type DeepReadingDocument } from "../models/DeepReading.js";
import type { UserDocument } from "../models/User.js";
import type { AppDependencies } from "../types/appDependencies.js";
import { drawCards, type CardDraw } from "./cardDrawService.js";
import { generateSummaryWithFallback } from "./dailyReadingService.js";
import { parseLocale } from "./localeService.js";
import { cleanReadingMarkdown } from "./markdownService.js";

const positions = [
  { position: "core", positionLabel: "問題核心" },
  { position: "hiddenInfluence", positionLabel: "隱藏影響" },
  { position: "advice", positionLabel: "行動建議" }
] as const;

type CreateDeepReadingInput = {
  locale?: unknown;
  question?: unknown;
  draftCards?: unknown;
  selectedIndexes?: unknown;
};

type UpdateVisibilityInput = {
  isSavedForHistory?: unknown;
};

export function createDeepReadingDraft() {
  return drawCards(9);
}

export async function createDeepReading(
  user: UserDocument,
  input: CreateDeepReadingInput,
  dependencies: AppDependencies
) {
  const locale = parseLocale(input.locale);
  const question = parseQuestion(input.question);
  const draftCards = parseDraftCards(input.draftCards);
  const selectedIndexes = parseSelectedIndexes(input.selectedIndexes);
  const selectedCards = selectedIndexes.map((selectedIndex, order) => ({
    ...positions[order],
    ...draftCards[selectedIndex]
  }));
  const markdownResult = cleanReadingMarkdown(
    await dependencies.llmService.generateDeepReading({
      locale,
      question,
      selectedCards
    })
  );
  const summary = await generateSummaryWithFallback(dependencies, locale, "deep", markdownResult, 60);

  return DeepReadingModel.create({
    userId: user._id,
    question,
    selectedCards,
    markdownResult,
    summary,
    resultLocale: locale,
    isSavedForHistory: false
  });
}

export async function listDeepReadingHistory(user: UserDocument) {
  return DeepReadingModel.find({
    userId: user._id,
    isSavedForHistory: true
  })
    .sort({ createdAt: -1 })
    .limit(10);
}

export async function getSavedDeepReading(user: UserDocument, id: string) {
  const reading = await findDeepReading(user, id, true);

  return reading;
}

export async function updateDeepReadingHistoryVisibility(
  user: UserDocument,
  id: string,
  input: UpdateVisibilityInput
) {
  if (typeof input.isSavedForHistory !== "boolean") {
    throw new ApiError(422, "VALIDATION_ERROR", "isSavedForHistory 必須是 boolean");
  }

  const reading = await findDeepReading(user, id, false);
  reading.isSavedForHistory = input.isSavedForHistory;
  await reading.save();

  return reading;
}

async function findDeepReading(user: UserDocument, id: string, savedOnly: boolean): Promise<DeepReadingDocument> {
  if (!mongoose.isValidObjectId(id)) {
    throw new ApiError(404, "NOT_FOUND", "找不到資源");
  }

  const query: Record<string, unknown> = {
    _id: id,
    userId: user._id
  };

  if (savedOnly) {
    query.isSavedForHistory = true;
  }

  const reading = await DeepReadingModel.findOne(query);

  if (!reading) {
    throw new ApiError(404, "NOT_FOUND", "找不到資源");
  }

  return reading;
}

function parseQuestion(value: unknown) {
  if (typeof value !== "string") {
    throw new ApiError(422, "VALIDATION_ERROR", "question 必須是字串");
  }

  const question = value.trim();

  if (question.length > 1000) {
    throw new ApiError(422, "VALIDATION_ERROR", "question 最多 1000 字");
  }

  return question;
}

function parseDraftCards(value: unknown): CardDraw[] {
  if (!Array.isArray(value) || value.length !== 9) {
    throw new ApiError(422, "VALIDATION_ERROR", "draftCards 必須剛好 9 張");
  }

  const cards = value.map((card) => parseCardDraw(card));
  const uniqueCardIds = new Set(cards.map((card) => card.cardId));

  if (uniqueCardIds.size !== cards.length) {
    throw new ApiError(422, "VALIDATION_ERROR", "draftCards 不可重複");
  }

  return cards;
}

function parseCardDraw(value: unknown): CardDraw {
  if (typeof value !== "object" || value === null) {
    throw new ApiError(422, "VALIDATION_ERROR", "card 格式不正確");
  }

  const card = value as {
    cardId?: unknown;
    orientation?: unknown;
  };

  if (typeof card.cardId !== "string" || !isValidCardId(card.cardId)) {
    throw new ApiError(422, "VALIDATION_ERROR", "cardId 不正確");
  }

  if (card.orientation !== "upright" && card.orientation !== "reversed") {
    throw new ApiError(422, "VALIDATION_ERROR", "orientation 不正確");
  }

  return {
    cardId: card.cardId,
    orientation: card.orientation as Orientation
  };
}

function parseSelectedIndexes(value: unknown) {
  if (!Array.isArray(value) || value.length !== 3) {
    throw new ApiError(422, "VALIDATION_ERROR", "selectedIndexes 必須剛好 3 個");
  }

  const indexes = value.map((item) => {
    if (!Number.isInteger(item) || item < 0 || item > 8) {
      throw new ApiError(422, "VALIDATION_ERROR", "selectedIndexes 必須是 0-8 的整數");
    }

    return item as number;
  });

  if (new Set(indexes).size !== indexes.length) {
    throw new ApiError(422, "VALIDATION_ERROR", "selectedIndexes 不可重複");
  }

  return indexes;
}

export function assertTarotCardCatalogComplete() {
  if (tarotCards.length !== 78) {
    throw new Error(`Expected 78 tarot cards, got ${tarotCards.length}`);
  }
}
