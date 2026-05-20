import { ApiError } from "../http/apiError.js";

export function cleanReadingMarkdown(markdown: string) {
  const cleaned = markdown.trim();

  if (!cleaned) {
    throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 回應為空");
  }

  if (containsUnsupportedMarkdown(cleaned)) {
    throw new ApiError(502, "LLM_UNAVAILABLE", "LLM 回應格式不符合預期", {
      internalCode: "LLM_INVALID_RESPONSE"
    });
  }

  return cleaned;
}

function containsUnsupportedMarkdown(markdown: string) {
  return (
    /<\/?[a-z][\s\S]*>/i.test(markdown) ||
    /!\[[^\]]*]\([^)]*\)/.test(markdown) ||
    /\[[^\]]+]\([^)]*\)/.test(markdown) ||
    /```/.test(markdown) ||
    markdown.split("\n").some((line) => looksLikeMarkdownTable(line.trim()))
  );
}

function looksLikeMarkdownTable(line: string) {
  return (line.match(/\|/g)?.length ?? 0) >= 2;
}

export function fallbackSummary(markdown: string, maxLength: number) {
  const plainText = markdown
    .replace(/^#{1,6}\s+/gm, "")
    .replace(/[*_>`-]/g, "")
    .replace(/\s+/g, " ")
    .trim();

  return plainText.slice(0, maxLength);
}
