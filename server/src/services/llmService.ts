import { ApiError } from "../http/apiError.js";
import type { WeatherSnapshot } from "../models/DailyReading.js";
import type { CardDraw } from "./cardDrawService.js";
import type { TimeContext } from "./timeContextService.js";

export type Locale = "zh-TW" | "en";

export type DailyReadingPromptContext = {
  locale: Locale;
  card: CardDraw;
  timeContext: TimeContext;
  weather: WeatherSnapshot;
};

export type DeepReadingPromptContext = {
  locale: Locale;
  question: string;
  selectedCards: Array<CardDraw & { position: string; positionLabel: string }>;
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
    return this.complete(`Create a daily tarot reading in ${context.locale}. Context: ${JSON.stringify(context)}`);
  }

  async generateDeepReading(context: DeepReadingPromptContext): Promise<string> {
    return this.complete(`Create a three-card tarot reading in ${context.locale}. Context: ${JSON.stringify(context)}`);
  }

  async generateSummary(context: SummaryPromptContext): Promise<string> {
    return this.complete(
      `Summarize this ${context.readingType} tarot reading in ${context.locale}, one plain sentence only: ${context.markdownResult}`
    );
  }

  private async complete(prompt: string): Promise<string> {
    const baseUrl = process.env.LLM_BASE_URL;
    const apiKey = process.env.LLM_API_KEY;
    const model = process.env.LLM_MODEL;

    if (!baseUrl || !apiKey || !model) {
      throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 尚未設定");
    }

    const response = await fetch(`${baseUrl.replace(/\/$/, "")}/chat/completions`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: "system",
            content: "Return only plain markdown for readings and plain text for summaries. Do not return HTML."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        temperature: 0.8
      })
    });

    if (!response.ok) {
      throw new ApiError(response.status === 504 ? 504 : 502, "LLM_UNAVAILABLE", "LLM 服務不可用");
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
}
