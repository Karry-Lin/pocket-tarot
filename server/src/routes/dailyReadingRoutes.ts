import { Router } from "express";

import { asyncHandler } from "../http/asyncHandler.js";
import { authenticateRequest } from "../http/authenticateRequest.js";
import { serializeDailyReading } from "../services/readingSerializer.js";
import { createTodayDailyReading, getTodayDailyReading } from "../services/dailyReadingService.js";
import { getActiveUser } from "../services/userService.js";
import type { AppDependencies } from "../types/appDependencies.js";

export function createDailyReadingRouter(dependencies: AppDependencies) {
  const router = Router();

  router.get(
    "/today",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const user = await getActiveUser(firebaseUser);
      const reading = await getTodayDailyReading(user);

      response.json({
        data: serializeDailyReading(reading)
      });
    })
  );

  router.post(
    "/today",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const user = await getActiveUser(firebaseUser);
      const result = await createTodayDailyReading(user, request.body, dependencies);

      response.status(result.created ? 201 : 200).json({
        data: serializeDailyReading(result.reading)
      });
    })
  );

  return router;
}
