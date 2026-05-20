export type ErrorCode =
  | "UNAUTHENTICATED"
  | "EMAIL_NOT_VERIFIED"
  | "PROFILE_NOT_FOUND"
  | "ACCOUNT_NOT_ACTIVE"
  | "ACCOUNT_DELETED"
  | "VALIDATION_ERROR"
  | "DAILY_READING_NOT_FOUND"
  | "LLM_UNAVAILABLE"
  | "LLM_TIMEOUT"
  | "LLM_INVALID_RESPONSE"
  | "ADMIN_UNAUTHORIZED"
  | "NOT_FOUND"
  | "INTERNAL_ERROR"
  | "EMAIL_ALREADY_REGISTERED";

export class ApiError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: ErrorCode,
    message: string,
    public readonly details: Record<string, unknown> = {}
  ) {
    super(message);
  }
}

export function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError;
}
