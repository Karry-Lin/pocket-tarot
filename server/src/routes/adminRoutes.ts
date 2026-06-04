import { Router } from "express";

import { ApiError } from "../http/apiError.js";
import { asyncHandler } from "../http/asyncHandler.js";
import type { AppDependencies } from "../types/appDependencies.js";
import {
  getAdminUserById,
  listAdminUsers,
  updateUserActivation,
  updateUserDeletion
} from "../services/userService.js";
import { serializeUser } from "../services/userSerializer.js";

export function createAdminRouter(dependencies: AppDependencies) {
  const router = Router();

  router.use((request, _response, next) => {
    if (!dependencies.adminApiKey || request.header("x-admin-key") !== dependencies.adminApiKey) {
      next(new ApiError(401, "ADMIN_UNAUTHORIZED", "Admin key 驗證失敗"));
      return;
    }

    next();
  });

  router.get(
    "/users",
    asyncHandler(async (request, response) => {
      const users = await listAdminUsers(request.query);

      response.json({
        data: users.map(serializeUser)
      });
    })
  );

  router.post(
    "/llm/test",
    asyncHandler(async (request, response) => {
      const prompt = validatePrompt(request.body?.prompt);
      const content = await dependencies.llmService.testPrompt(prompt);

      response.json({
        data: {
          content,
          model: process.env.LLM_MODEL ?? null
        }
      });
    })
  );

  router.get(
    "/users/:id",
    asyncHandler(async (request, response) => {
      const user = await getAdminUserById(String(request.params.id));

      response.json({
        data: {
          user: serializeUser(user)
        }
      });
    })
  );

  router.patch(
    "/users/:id/activation",
    asyncHandler(async (request, response) => {
      const user = await updateUserActivation(String(request.params.id), request.body?.isActive);

      response.json({
        data: {
          user: serializeUser(user)
        }
      });
    })
  );

  router.patch(
    "/users/:id/deletion",
    asyncHandler(async (request, response) => {
      const user = await updateUserDeletion(String(request.params.id), request.body?.deleted);

      response.json({
        data: {
          user: serializeUser(user)
        }
      });
    })
  );

  return router;
}

function validatePrompt(value: unknown): string {
  if (typeof value !== "string") {
    throw new ApiError(422, "VALIDATION_ERROR", "prompt 必須是字串");
  }

  const prompt = value.trim();
  if (prompt.length === 0) {
    throw new ApiError(422, "VALIDATION_ERROR", "prompt 不可為空");
  }

  if (prompt.length > 8000) {
    throw new ApiError(422, "VALIDATION_ERROR", "prompt 不可超過 8000 字元");
  }

  return prompt;
}
