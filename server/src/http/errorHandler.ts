import type { ErrorRequestHandler } from "express";

import { isApiError } from "./apiError.js";

export const errorHandler: ErrorRequestHandler = (error, _request, response, _next) => {
  if (isApiError(error)) {
    response.status(error.statusCode).json({
      error: {
        code: error.code,
        message: error.message,
        details: error.details
      }
    });
    return;
  }

  console.error(error);
  response.status(500).json({
    error: {
      code: "INTERNAL_ERROR",
      message: "伺服器發生未預期錯誤",
      details: {}
    }
  });
};
