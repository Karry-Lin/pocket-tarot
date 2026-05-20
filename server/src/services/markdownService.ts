import { ApiError } from "../http/apiError.js";

export function cleanReadingMarkdown(markdown: string) {
  const cleaned = markdown.trim();

  if (!cleaned) {
    throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 回應為空");
  }

  if (/<\/?[a-z][\s\S]*>/i.test(cleaned) || /!\[[^\]]*]\([^)]*\)/.test(cleaned) || /```/.test(cleaned)) {
    throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 回應格式不符合預期", {
      internalCode: "LLM_INVALID_RESPONSE"
    });
  }

  return cleaned;
}

export function fallbackSummary(markdown: string, maxLength: number) {
  const plainText = markdown
    .replace(/^#{1,6}\s+/gm, "")
    .replace(/[*_>`-]/g, "")
    .replace(/\s+/g, " ")
    .trim();

  return plainText.slice(0, maxLength);
}
