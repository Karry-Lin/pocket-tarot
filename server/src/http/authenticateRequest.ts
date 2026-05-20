import type { Request } from "express";

import { ApiError } from "./apiError.js";
import type { DecodedFirebaseToken, FirebaseAuthService } from "../services/firebaseAuthService.js";

export async function authenticateRequest(
  request: Request,
  firebaseAuthService: FirebaseAuthService
): Promise<DecodedFirebaseToken> {
  const authorization = request.header("authorization");
  const match = authorization?.match(/^Bearer\s+(.+)$/i);

  if (!match) {
    throw new ApiError(401, "UNAUTHENTICATED", "請先登入");
  }

  try {
    return await firebaseAuthService.verifyIdToken(match[1]);
  } catch {
    throw new ApiError(401, "UNAUTHENTICATED", "Firebase token 驗證失敗");
  }
}
