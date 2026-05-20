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
