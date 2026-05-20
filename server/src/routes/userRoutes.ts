import { Router } from "express";

import { asyncHandler } from "../http/asyncHandler.js";
import { authenticateRequest } from "../http/authenticateRequest.js";
import type { AppDependencies } from "../types/appDependencies.js";
import { getUserMe, updateCurrentUser } from "../services/userService.js";
import { serializeUser } from "../services/userSerializer.js";

export function createUserRouter(dependencies: AppDependencies) {
  const router = Router();

  router.get(
    "/me",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const result = await getUserMe(firebaseUser);

      response.json({
        data: {
          user: serializeUser(result.user),
          stats: result.stats
        }
      });
    })
  );

  router.patch(
    "/me",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const user = await updateCurrentUser(firebaseUser, request.body);

      response.json({
        data: {
          user: serializeUser(user)
        }
      });
    })
  );

  return router;
}
