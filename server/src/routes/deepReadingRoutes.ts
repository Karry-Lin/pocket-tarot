import { Router } from "express";

import { asyncHandler } from "../http/asyncHandler.js";
import { authenticateRequest } from "../http/authenticateRequest.js";
import {
  createDeepReading,
  createDeepReadingDraft,
  getSavedDeepReading,
  listDeepReadingHistory,
  updateDeepReadingHistoryVisibility
} from "../services/deepReadingService.js";
import {
  serializeDeepReading,
  serializeDeepReadingHistory
} from "../services/readingSerializer.js";
import { getActiveUser } from "../services/userService.js";
import type { AppDependencies } from "../types/appDependencies.js";

export function createDeepReadingRouter(dependencies: AppDependencies) {
  const router = Router();

  router.post(
    "/drafts",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      await getActiveUser(firebaseUser);

      response.json({
        data: {
          draftCards: createDeepReadingDraft()
        }
      });
    })
  );

  router.post(
    "/",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const user = await getActiveUser(firebaseUser);
      const reading = await createDeepReading(user, request.body, dependencies);

      response.status(201).json({
        data: serializeDeepReading(reading)
      });
    })
  );

  router.get(
    "/history",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const user = await getActiveUser(firebaseUser);
      const readings = await listDeepReadingHistory(user);

      response.json({
        data: readings.map(serializeDeepReadingHistory)
      });
    })
  );

  router.get(
    "/:id",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const user = await getActiveUser(firebaseUser);
      const reading = await getSavedDeepReading(user, String(request.params.id));

      response.json({
        data: serializeDeepReading(reading)
      });
    })
  );

  router.patch(
    "/:id/history-visibility",
    asyncHandler(async (request, response) => {
      const firebaseUser = await authenticateRequest(request, dependencies.firebaseAuthService);
      const user = await getActiveUser(firebaseUser);
      const reading = await updateDeepReadingHistoryVisibility(user, String(request.params.id), request.body);

      response.json({
        data: {
          id: reading._id.toString(),
          isSavedForHistory: reading.isSavedForHistory
        }
      });
    })
  );

  return router;
}
