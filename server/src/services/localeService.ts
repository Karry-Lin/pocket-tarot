import { ApiError } from "../http/apiError.js";

export function parseLocale(value: unknown): "zh-TW" | "en" {
  if (value === "zh-TW" || value === "en") {
    return value;
  }

  throw new ApiError(422, "VALIDATION_ERROR", "locale 必須是 zh-TW 或 en");
}
