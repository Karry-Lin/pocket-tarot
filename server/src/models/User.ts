import mongoose, { Schema, type HydratedDocument, type Model } from "mongoose";

export type UserAttrs = {
  firebaseUid: string;
  email: string;
  emailNormalized: string;
  displayName: string;
  providerIds: string[];
  isActive: boolean;
  activatedAt: Date | null;
  lastLoginAt: Date | null;
  deletedAt: Date | null;
};

export type UserDocument = HydratedDocument<
  UserAttrs
>;

const userSchema = new Schema<UserAttrs>(
  {
    firebaseUid: {
      type: String,
      required: true,
      trim: true
    },
    email: {
      type: String,
      required: true,
      trim: true
    },
    emailNormalized: {
      type: String,
      required: true,
      lowercase: true,
      trim: true
    },
    displayName: {
      type: String,
      required: true,
      trim: true,
      minlength: 1,
      maxlength: 16
    },
    providerIds: {
      type: [String],
      required: true,
      default: []
    },
    isActive: {
      type: Boolean,
      required: true,
      default: false
    },
    activatedAt: {
      type: Date,
      default: null
    },
    lastLoginAt: {
      type: Date,
      default: null
    },
    deletedAt: {
      type: Date,
      default: null
    }
  },
  {
    collection: "users",
    timestamps: true
  }
);

userSchema.index({ firebaseUid: 1 }, { unique: true });
userSchema.index({ emailNormalized: 1 }, { unique: true });
userSchema.index({ isActive: 1 });
userSchema.index({ deletedAt: 1 });

export const UserModel: Model<UserAttrs> =
  mongoose.models.User ?? mongoose.model<UserAttrs>("User", userSchema);
