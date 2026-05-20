import type { UserDocument } from "../models/User.js";

type SerializableUser = UserDocument & {
  createdAt?: Date;
  updatedAt?: Date;
};

export function serializeUser(user: SerializableUser) {
  return {
    id: user._id.toString(),
    firebaseUid: user.firebaseUid,
    email: user.email,
    displayName: user.displayName,
    providerIds: user.providerIds,
    isActive: user.isActive,
    createdAt: requireDate(user.createdAt, "createdAt").toISOString(),
    activatedAt: user.activatedAt?.toISOString() ?? null,
    lastLoginAt: user.lastLoginAt?.toISOString() ?? null,
    deletedAt: user.deletedAt?.toISOString() ?? null
  };
}

function requireDate(value: Date | undefined, fieldName: string) {
  if (!value) {
    throw new Error(`User document missing ${fieldName}`);
  }

  return value;
}
