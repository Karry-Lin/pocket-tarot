import mongoose, { Schema, type HydratedDocument, type Model, type Types } from "mongoose";

import type { Orientation } from "../data/tarotCards.js";

export type WeatherSnapshot = {
  enabled: boolean;
  status: "success" | "disabled" | "permission_denied" | "unavailable";
  provider: "open-meteo" | null;
  latitude: number | null;
  longitude: number | null;
  locationName?: string | null;
  timezone: "Asia/Taipei";
  current: Record<string, unknown> | null;
  errorCode: string | null;
};

export type DailyReadingAttrs = {
  userId: Types.ObjectId;
  localDate: string;
  card: {
    cardId: string;
    orientation: Orientation;
  };
  timeContext: {
    timezone: "Asia/Taipei";
    localDate: string;
    dayOfWeek: string;
    timeOfDay: "morning" | "afternoon" | "evening" | "night";
  };
  weather: WeatherSnapshot;
  markdownResult: string;
  summary: string;
  resultLocale: "zh-TW" | "en";
};

export type DailyReadingDocument = HydratedDocument<DailyReadingAttrs>;

const dailyReadingSchema = new Schema<DailyReadingAttrs>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    localDate: {
      type: String,
      required: true
    },
    card: {
      cardId: {
        type: String,
        required: true
      },
      orientation: {
        type: String,
        required: true,
        enum: ["upright", "reversed"]
      }
    },
    timeContext: {
      timezone: {
        type: String,
        required: true,
        default: "Asia/Taipei"
      },
      localDate: {
        type: String,
        required: true
      },
      dayOfWeek: {
        type: String,
        required: true
      },
      timeOfDay: {
        type: String,
        required: true,
        enum: ["morning", "afternoon", "evening", "night"]
      }
    },
    weather: {
      type: Schema.Types.Mixed,
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
    }
  },
  {
    collection: "daily_readings",
    timestamps: true
  }
);

dailyReadingSchema.index({ userId: 1, localDate: 1 }, { unique: true });
dailyReadingSchema.index({ userId: 1, createdAt: -1 });

export const DailyReadingModel: Model<DailyReadingAttrs> =
  mongoose.models.DailyReading ?? mongoose.model<DailyReadingAttrs>("DailyReading", dailyReadingSchema);
