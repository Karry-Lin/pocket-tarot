import mongoose from "mongoose";

import { ApiError } from "../http/apiError.js";
import { DailyReadingModel } from "../models/DailyReading.js";
import { DeepReadingModel } from "../models/DeepReading.js";
import { UserModel, type UserDocument } from "../models/User.js";
import type { DecodedFirebaseToken } from "./firebaseAuthService.js";

type RegisterProfileInput = {
  displayName?: unknown;
  providerIds?: unknown;
};

type UpdateProfileInput = {
  displayName?: unknown;
};

type AdminUserFilter = {
  deleted?: unknown;
  isActive?: unknown;
  email?: unknown;
};

export async function registerProfile(firebaseUser: DecodedFirebaseToken, input: RegisterProfileInput) {
  const providerIds = parseProviderIds(
    firebaseUser.providerIds.length > 0 ? firebaseUser.providerIds : input.providerIds,
    []
  );

  if (providerIds.includes("password") && !firebaseUser.emailVerified) {
    throw new ApiError(403, "EMAIL_NOT_VERIFIED", "Email 尚未驗證");
  }

  const email = resolveProfileEmail(firebaseUser, providerIds);
  const emailNormalized = normalizeEmail(email);
  const now = new Date();
  const existingByUid = await UserModel.findOne({ firebaseUid: firebaseUser.uid });

  if (existingByUid) {
    if (existingByUid.deletedAt) {
      throw new ApiError(403, "ACCOUNT_DELETED", "帳號已刪除");
    }

    existingByUid.lastLoginAt = now;
    await existingByUid.save();

    return {
      user: existingByUid,
      created: false
    };
  }

  const existingByEmail = await UserModel.findOne({ emailNormalized });
  if (existingByEmail) {
    throw new ApiError(409, "EMAIL_ALREADY_REGISTERED", "Email 已註冊");
  }

  const isActive = newUsersActiveByDefault();
  const user = await UserModel.create({
    firebaseUid: firebaseUser.uid,
    email,
    emailNormalized,
    displayName: parseDisplayName(input.displayName),
    providerIds,
    isActive,
    activatedAt: isActive ? now : null,
    lastLoginAt: now,
    deletedAt: null
  });

  return {
    user,
    created: true
  };
}

export async function getUserMe(firebaseUser: DecodedFirebaseToken) {
  const user = await findCurrentUser(firebaseUser);
  const [dailyReadingCount, deepReadingCount] = await Promise.all([
    DailyReadingModel.countDocuments({ userId: user._id }),
    DeepReadingModel.countDocuments({ userId: user._id })
  ]);

  return {
    user,
    stats: {
      dailyReadingCount,
      deepReadingCount
    }
  };
}

export async function getActiveUser(firebaseUser: DecodedFirebaseToken) {
  const user = await findCurrentUser(firebaseUser);
  ensureActive(user);

  return user;
}

export async function updateCurrentUser(firebaseUser: DecodedFirebaseToken, input: UpdateProfileInput) {
  const user = await findCurrentUser(firebaseUser);
  ensureActive(user);

  user.displayName = parseDisplayName(input.displayName);
  await user.save();

  return user;
}

export async function listAdminUsers(filter: AdminUserFilter) {
  const query: Record<string, unknown> = {};
  const deleted = typeof filter.deleted === "string" ? filter.deleted : "false";

  if (deleted === "true") {
    query.deletedAt = { $ne: null };
  } else if (deleted !== "all") {
    query.deletedAt = null;
  }

  if (typeof filter.isActive === "string") {
    query.isActive = filter.isActive === "true";
  }

  if (typeof filter.email === "string" && filter.email.trim()) {
    query.emailNormalized = {
      $regex: escapeRegex(normalizeEmail(filter.email)),
      $options: "i"
    };
  }

  return UserModel.find(query).sort({ createdAt: -1 });
}

export async function getAdminUserById(id: string) {
  const user = await findUserById(id);

  return user;
}

export async function updateUserActivation(id: string, isActiveInput: unknown) {
  if (typeof isActiveInput !== "boolean") {
    throw new ApiError(422, "VALIDATION_ERROR", "isActive 必須是 boolean");
  }

  const user = await findUserById(id);
  user.isActive = isActiveInput;

  if (isActiveInput && !user.activatedAt) {
    user.activatedAt = new Date();
  }

  await user.save();

  return user;
}

export async function updateUserDeletion(id: string, deletedInput: unknown) {
  if (typeof deletedInput !== "boolean") {
    throw new ApiError(422, "VALIDATION_ERROR", "deleted 必須是 boolean");
  }

  const user = await findUserById(id);
  user.deletedAt = deletedInput ? new Date() : null;
  await user.save();

  return user;
}

async function findCurrentUser(firebaseUser: DecodedFirebaseToken) {
  const user = await UserModel.findOne({ firebaseUid: firebaseUser.uid });

  if (!user) {
    throw new ApiError(404, "PROFILE_NOT_FOUND", "找不到使用者 profile");
  }

  if (user.deletedAt) {
    throw new ApiError(403, "ACCOUNT_DELETED", "帳號已刪除");
  }

  user.lastLoginAt = new Date();
  await user.save();

  return user;
}

function ensureActive(user: UserDocument) {
  if (!user.isActive) {
    throw new ApiError(403, "ACCOUNT_NOT_ACTIVE", "帳號尚未啟用");
  }
}

async function findUserById(id: string) {
  if (!mongoose.isValidObjectId(id)) {
    throw new ApiError(404, "NOT_FOUND", "找不到資源");
  }

  const user = await UserModel.findById(id);
  if (!user) {
    throw new ApiError(404, "NOT_FOUND", "找不到資源");
  }

  return user;
}

function parseDisplayName(value: unknown) {
  if (typeof value !== "string") {
    throw new ApiError(422, "VALIDATION_ERROR", "displayName 必須是字串");
  }

  const displayName = value.trim();

  if (displayName.length < 1 || displayName.length > 16) {
    throw new ApiError(422, "VALIDATION_ERROR", "displayName 長度必須為 1-16 字");
  }

  return displayName;
}

function parseProviderIds(value: unknown, fallback: string[]) {
  const providerIds = Array.isArray(value) ? value : fallback;

  if (!providerIds.every((providerId) => typeof providerId === "string" && providerId.trim().length > 0)) {
    throw new ApiError(422, "VALIDATION_ERROR", "providerIds 必須是非空字串陣列");
  }

  return providerIds.map((providerId) => providerId.trim());
}

function normalizeEmail(email: string) {
  return email.trim().toLowerCase();
}

function resolveProfileEmail(firebaseUser: DecodedFirebaseToken, providerIds: string[]) {
  if (firebaseUser.email) {
    return firebaseUser.email;
  }

  if (providerIds.includes("playgames.google.com")) {
    return `playgames+${emailSafeFirebaseUid(firebaseUser.uid)}@pocket-tarot.local`;
  }

  throw new ApiError(422, "VALIDATION_ERROR", "Firebase token 缺少 email");
}

function emailSafeFirebaseUid(uid: string) {
  const localPart = uid
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9._+-]/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");

  return localPart || "unknown";
}

function escapeRegex(value: string) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function newUsersActiveByDefault() {
  const value = process.env.NEW_USERS_ACTIVE_BY_DEFAULT;
  if (value == null || value.trim() === "") {
    return true;
  }

  return !["0", "false", "off", "no"].includes(value.trim().toLowerCase());
}
