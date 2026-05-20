import mongoose, { Schema, type HydratedDocument, type Model, type Types } from "mongoose";

import type { Orientation } from "../data/tarotCards.js";

export type DeepReadingAttrs = {
  userId: Types.ObjectId;
  question: string;
  selectedCards: Array<{
    position: "core" | "hiddenInfluence" | "advice";
    positionLabel: string;
    cardId: string;
    orientation: Orientation;
  }>;
  markdownResult: string;
  summary: string;
  resultLocale: "zh-TW" | "en";
  isSavedForHistory: boolean;
};

export type DeepReadingDocument = HydratedDocument<DeepReadingAttrs>;

const deepReadingSchema = new Schema<DeepReadingAttrs>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    question: {
      type: String,
      default: "",
      maxlength: 1000
    },
    selectedCards: {
      type: [
        {
          position: {
            type: String,
            required: true,
            enum: ["core", "hiddenInfluence", "advice"]
          },
          positionLabel: {
            type: String,
            required: true
          },
          cardId: {
            type: String,
            required: true
          },
          orientation: {
            type: String,
            required: true,
            enum: ["upright", "reversed"]
          }
        }
      ],
      required: true
    },
    markdownResult: {
      type: String,
      required: true
    },
    summary: {
      type: String,
      required: true
    },
    resultLocale: {
      type: String,
      required: true,
      enum: ["zh-TW", "en"]
    },
    isSavedForHistory: {
      type: Boolean,
      required: true,
      default: false
    }
  },
  {
    collection: "deep_readings",
    timestamps: true
  }
);

deepReadingSchema.index({ userId: 1, isSavedForHistory: 1, createdAt: -1 });
deepReadingSchema.index({ userId: 1, createdAt: -1 });

export const DeepReadingModel: Model<DeepReadingAttrs> =
  mongoose.models.DeepReading ?? mongoose.model<DeepReadingAttrs>("DeepReading", deepReadingSchema);
