import { ApiError } from "../http/apiError.js";
import type { TarotCard } from "../data/tarotCards.js";
import type { WeatherSnapshot } from "../models/DailyReading.js";
import type { CardDraw } from "./cardDrawService.js";
import type { TimeContext } from "./timeContextService.js";

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
    return this.complete(
      `Create a daily tarot reading in ${context.locale}. Context: ${JSON.stringify(context)}`,
      envNumber("LLM_READING_TEMPERATURE", 0.8)
    );
  }

  async generateDeepReading(context: DeepReadingPromptContext): Promise<string> {
    return this.complete(
      `Create a three-card tarot reading in ${context.locale}. Context: ${JSON.stringify(context)}`,
      envNumber("LLM_READING_TEMPERATURE", 0.8)
    );
  }

  async generateSummary(context: SummaryPromptContext): Promise<string> {
    return this.complete(
      `Summarize this ${context.readingType} tarot reading in ${context.locale}, one plain sentence only: ${context.markdownResult}`,
      envNumber("LLM_SUMMARY_TEMPERATURE", 0.3)
    );
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
