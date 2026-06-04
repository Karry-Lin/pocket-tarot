import { ApiError } from "../http/apiError.js";
import { type TarotCard, getCardDisplayName } from "../data/tarotCards.js";
import type { WeatherSnapshot } from "../models/DailyReading.js";
import type { CardDraw } from "./cardDrawService.js";
import type { TimeContext } from "./timeContextService.js";
import { fallbackSummary } from "./markdownService.js";

export type Locale = "zh-TW" | "en";
type PromptCard = TarotCard & CardDraw;

export type DailyReadingPromptContext = {
  locale: Locale;
  card: PromptCard;
  timeContext: TimeContext;
  weather: WeatherSnapshot;
};

export type DeepReadingPromptContext = {
  locale: Locale;
  question: string;
  selectedCards: Array<PromptCard & { position: string; positionLabel: string }>;
};

export type SummaryPromptContext = {
  locale: Locale;
  readingType: "daily" | "deep";
  markdownResult: string;
};

export interface LlmService {
  generateDailyReading(context: DailyReadingPromptContext): Promise<string>;
  generateDeepReading(context: DeepReadingPromptContext): Promise<string>;
  generateSummary(context: SummaryPromptContext): Promise<string>;
}

export class ChatCompletionsLlmService implements LlmService {
  async generateDailyReading(context: DailyReadingPromptContext): Promise<string> {
    try {
      const maxAttempts = 3;
      let lastContent = "";
      for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        const content = await this.complete(
          buildDailyReadingPrompt(context),
          envNumber("LLM_READING_TEMPERATURE", 0.8)
        );
        if (isValidDailyReadingFormat(content, context.locale)) {
          return content;
        }
        lastContent = content;
        if (attempt < maxAttempts) {
          console.warn(`Daily reading LLM format mismatch (attempt ${attempt}/${maxAttempts}). Retrying...`);
        }
      }
      if (isValidDailyReadingFormat(lastContent, context.locale)) {
        return lastContent;
      }
      throw new Error("LLM response format invalid after max attempts");
    } catch (error) {
      console.error("generateDailyReading failed, using local mock fallback:", error);
      return getDailyReadingFallback(context);
    }
  }

  async generateDeepReading(context: DeepReadingPromptContext): Promise<string> {
    try {
      const maxAttempts = 3;
      let lastContent = "";
      for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        const content = await this.complete(
          buildDeepReadingPrompt(context),
          envNumber("LLM_READING_TEMPERATURE", 0.8)
        );
        if (isValidDeepReadingFormat(content, context.locale)) {
          return content;
        }
        lastContent = content;
        if (attempt < maxAttempts) {
          console.warn(`Deep reading LLM format mismatch (attempt ${attempt}/${maxAttempts}). Retrying...`);
        }
      }
      if (isValidDeepReadingFormat(lastContent, context.locale)) {
        return lastContent;
      }
      throw new Error("LLM response format invalid after max attempts");
    } catch (error) {
      console.error("generateDeepReading failed, using local mock fallback:", error);
      return getDeepReadingFallback(context);
    }
  }

  async generateSummary(context: SummaryPromptContext): Promise<string> {
    try {
      return await this.complete(
        buildSummaryPrompt(context),
        envNumber("LLM_SUMMARY_TEMPERATURE", 0.3)
      );
    } catch (error) {
      console.error("generateSummary failed, using fallbackSummary:", error);
      const limit = context.readingType === "daily" ? 40 : 60;
      return fallbackSummary(context.markdownResult, limit);
    }
  }

  private async complete(prompt: string, temperature: number): Promise<string> {
    const baseUrl = process.env.LLM_BASE_URL;
    const apiKey = process.env.LLM_API_KEY;
    const model = process.env.LLM_MODEL;

    if (!baseUrl || !apiKey || !model) {
      throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 尚未設定");
    }

    const endpoint = `${baseUrl.replace(/\/$/, "")}/chat/completions`;
    const timeoutMs = envInteger("LLM_TIMEOUT_MS", 30000);
    const maxRetries = envInteger("LLM_MAX_RETRIES", 1);

    for (let attempt = 0; attempt <= maxRetries; attempt += 1) {
      try {
        return await sendChatCompletion({
          endpoint,
          apiKey,
          model,
          prompt,
          temperature,
          timeoutMs
        });
      } catch (error) {
        if (attempt >= maxRetries || !isRetryableLlmError(error)) {
          throw error;
        }
      }
    }

    throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 服務不可用");
  }
}

function buildDailyReadingPrompt(context: DailyReadingPromptContext) {
  const sections =
    context.locale === "zh-TW"
      ? ["## 今日牌義", "## 今日提醒", "## 行動建議"]
      : ["## Card Meaning", "## Daily Reminder", "## Action Advice"];

  return [
    `Create a daily tarot reading in ${context.locale}.`,
    "Use exactly these markdown sections in this order:",
    ...sections,
    safeMarkdownInstruction(),
    `Context JSON: ${JSON.stringify(context)}`
  ].join("\n");
}

function buildDeepReadingPrompt(context: DeepReadingPromptContext) {
  const sections =
    context.locale === "zh-TW"
      ? ["## 問題核心", "## 隱藏影響", "## 行動建議", "## 總結"]
      : ["## Core Question", "## Hidden Influence", "## Action Advice", "## Summary"];
  const questionInstruction =
    context.question.trim().length === 0
      ? "The question is empty. Treat it as「未指定問題的整體狀態占卜」and do not ask for more information."
      : "Answer the user's question directly.";

  return [
    `Create a three-card tarot reading in ${context.locale}.`,
    questionInstruction,
    "Use exactly these markdown sections in this order:",
    ...sections,
    safeMarkdownInstruction(),
    `Context JSON: ${JSON.stringify(context)}`
  ].join("\n");
}

function buildSummaryPrompt(context: SummaryPromptContext) {
  const limit =
    context.locale === "zh-TW"
      ? context.readingType === "daily"
        ? "40 Chinese characters"
        : "60 Chinese characters"
      : context.readingType === "daily"
        ? "25 English words"
        : "35 English words";

  return [
    `Summarize this ${context.readingType} tarot reading in ${context.locale}.`,
    `Return one plain sentence within ${limit}.`,
    "Do not use markdown. Do not use meta phrases like 'based on the above'.",
    `Markdown result: ${context.markdownResult}`
  ].join("\n");
}

function safeMarkdownInstruction() {
  return [
    "Use only headings, paragraphs, bold, italic, ordered or unordered lists, blockquotes, and horizontal rules.",
    "Do not use HTML, images, tables, code blocks, or links."
  ].join(" ");
}

type ChatCompletionRequest = {
  endpoint: string;
  apiKey: string;
  model: string;
  prompt: string;
  temperature: number;
  timeoutMs: number;
};

async function sendChatCompletion(options: ChatCompletionRequest): Promise<string> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), Math.max(1, options.timeoutMs));

  let response: Response;
  try {
    response = await fetch(options.endpoint, {
      method: "POST",
      signal: controller.signal,
      headers: {
        Authorization: `Bearer ${options.apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: options.model,
        messages: [
          {
            role: "system",
            content: "Return only plain markdown for readings and plain text for summaries. Do not return HTML."
          },
          {
            role: "user",
            content: options.prompt
          }
        ],
        temperature: options.temperature
      })
    });
  } catch (error) {
    if (isAbortError(error)) {
      throw new ApiError(504, "LLM_TIMEOUT", "LLM 請求逾時", {
        retryable: true
      });
    }

    throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 服務不可用", {
      retryable: true
    });
  } finally {
    clearTimeout(timeout);
  }

  if (!response.ok) {
    if (response.status === 504) {
      throw new ApiError(504, "LLM_TIMEOUT", "LLM 請求逾時", {
        providerStatus: response.status,
        retryable: true
      });
    }

    throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 服務不可用", {
      providerStatus: response.status,
      retryable: response.status >= 500
    });
  }

  const body = (await response.json()) as {
    choices?: Array<{
      message?: {
        content?: unknown;
      };
    }>;
  };
  const content = body.choices?.[0]?.message?.content;

  if (typeof content !== "string") {
    throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 回應格式不符合預期", {
      internalCode: "LLM_INVALID_RESPONSE"
    });
  }

  return content;
}

function isRetryableLlmError(error: unknown): boolean {
  return error instanceof ApiError && error.details.retryable === true;
}

function isAbortError(error: unknown): boolean {
  return error instanceof Error && error.name === "AbortError";
}

function envNumber(name: string, fallback: number): number {
  const value = process.env[name];
  if (value === undefined) {
    return fallback;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function envInteger(name: string, fallback: number): number {
  const value = process.env[name];
  if (value === undefined) {
    return fallback;
  }

  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : fallback;
}

export function isValidDailyReadingFormat(content: string, locale: Locale): boolean {
  if (!content) return false;
  const headers =
    locale === "zh-TW"
      ? [/##\s*今日牌義/, /##\s*今日提醒/, /##\s*行動建議/]
      : [/##\s*Card Meaning/i, /##\s*Daily Reminder/i, /##\s*Action Advice/i];

  return headers.every((regex) => regex.test(content));
}

export function isValidDeepReadingFormat(content: string, locale: Locale): boolean {
  if (!content) return false;
  const headers =
    locale === "zh-TW"
      ? [/##\s*問題核心/, /##\s*隱藏影響/, /##\s*行動建議/, /##\s*總結/]
      : [/##\s*Core Question/i, /##\s*Hidden Influence/i, /##\s*Action Advice/i, /##\s*Summary/i];

  return headers.every((regex) => regex.test(content));
}

function getDailyReadingFallback(context: DailyReadingPromptContext): string {
  const isZh = context.locale === "zh-TW";
  const cardName = getCardDisplayName(context.card.cardId, context.locale);
  const orientationStr = context.card.orientation === "upright" ? (isZh ? "正位" : "Upright") : (isZh ? "逆位" : "Reversed");
  
  if (isZh) {
    return `## 今日牌義\n今日你抽到了 **${cardName} (${orientationStr})**。這張牌代表著此時此刻你所面臨的核心能量。請細心感受卡牌帶給你的直覺啟發。\n\n## 今日提醒\n在今天的日常生活中，請保持覺察，注意周遭細微的變化。這張牌提醒你，一切外在的顯現都是內在心境的投射。\n\n## 行動建議\n建議你今天多給自己一些安靜的時間，傾聽內心的聲音。在做決定前，深呼吸，順應直覺的引導前行。`;
  } else {
    return `## Card Meaning\nToday you drew **${cardName} (${orientationStr})**. This card represents the core energy surrounding you right now. Listen closely to the intuitive insights it offers.\n\n## Daily Reminder\nKeep an open heart and stay aware of your environment today. Remember that external events often mirror your inner state.\n\n## Action Advice\nWe suggest taking some quiet time for reflection today. Breathe deeply, trust your intuition, and proceed with mindful steps.`;
  }
}

function getDeepReadingFallback(context: DeepReadingPromptContext): string {
  const isZh = context.locale === "zh-TW";
  const cardNames = context.selectedCards.map(c => `${getCardDisplayName(c.cardId, context.locale)} (${c.orientation === "upright" ? (isZh ? "正位" : "Upright") : (isZh ? "逆位" : "Reversed")})`).join(", ");

  if (isZh) {
    return `## 問題核心\n關於你的提問「${context.question || "未指定問題的整體狀態占卜"}」，目前核心點在於你選取的第一張牌所對應的象徵。這指引你重新檢視內在的真實想法。\n\n## 隱藏影響\n你所選取的第二張牌揭示了潛意識中的隱藏影響。有些你未曾察覺的因素正在暗中作用，影響著你的決策與感受。\n\n## 行動建議\n第三張牌為你提供了實用的行動建議。建議你接納當下的現狀，放手不必要的執著，並採取主動與溫和的溝通方式。\n\n## 總結\n綜合以上卡牌（${cardNames}），這次占卜的核心啟示是：保持平靜與信任，所有的經歷都是心靈成長的寶貴資產。`;
  } else {
    return `## Core Question\nRegarding your question "${context.question || "General Reading"}", the core issue is represented by your first card. It guides you to examine your true thoughts.\n\n## Hidden Influence\nYour second card reveals the hidden influences in your subconscious. Unseen forces or feelings are currently shaping your decisions.\n\n## Action Advice\nYour third card offers practical advice. We recommend accepting the current situation, letting go of unnecessary attachments, and communicating gently.\n\n## Summary\nCombining these cards (${cardNames}), the final guidance is: stay calm and trust the process. Every experience is a valuable lesson for your spiritual growth.`;
  }
}
