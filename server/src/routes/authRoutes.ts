import { Router } from "express";

import { asyncHandler } from "../http/asyncHandler.js";
import { authenticateRequest } from "../http/authenticateRequest.js";
import type { AppDependencies } from "../types/appDependencies.js";
import { registerProfile } from "../services/userService.js";
import { serializeUser } from "../services/userSerializer.js";

export function createAuthRouter(dependencies: AppDependencies) {
  const router = Router();

  router.post(
    "/register-profile",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const result = await registerProfile(firebaseUser, request.body);

      response.status(result.created ? 201 : 200).json({
        data: {
          user: serializeUser(result.user)
        }
      });
    })
  );

  return router;
}
