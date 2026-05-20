import type { WeatherSnapshot } from "../models/DailyReading.js";

export type WeatherInput = {
  enabled?: unknown;
  status?: unknown;
  latitude?: unknown;
  longitude?: unknown;
};

export interface WeatherService {
  resolveWeather(input: WeatherInput): Promise<WeatherSnapshot>;
}

export class OpenMeteoWeatherService implements WeatherService {
  async resolveWeather(input: WeatherInput): Promise<WeatherSnapshot> {
    const enabled = input.enabled === true;
    const status = typeof input.status === "string" ? input.status : enabled ? "unavailable" : "disabled";
    const latitude = typeof input.latitude === "number" ? input.latitude : null;
    const longitude = typeof input.longitude === "number" ? input.longitude : null;

    if (!enabled || status === "disabled") {
      return baseSnapshot(false, "disabled", latitude, longitude);
    }

    if (status === "permission_denied") {
      return baseSnapshot(true, "permission_denied", null, null);
    }

    if (status !== "success" || latitude === null || longitude === null) {
      return baseSnapshot(enabled, "unavailable", latitude, longitude, "WEATHER_LOCATION_UNAVAILABLE");
    }

    try {
      const params = new URLSearchParams({
        latitude: String(latitude),
        longitude: String(longitude),
        timezone: "Asia/Taipei",
        current:
          "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m"
      });
      const response = await fetch(`https://api.open-meteo.com/v1/forecast?${params.toString()}`);

      if (!response.ok) {
        return baseSnapshot(true, "unavailable", latitude, longitude, "OPEN_METEO_UNAVAILABLE");
      }

      const body = (await response.json()) as {
        current?: Record<string, unknown>;
      };

      return {
        enabled: true,
        status: "success",
        provider: "open-meteo",
        latitude,
        longitude,
        timezone: "Asia/Taipei",
        current: normalizeCurrentWeather(body.current ?? {}),
        errorCode: null
      };
    } catch {
      return baseSnapshot(true, "unavailable", latitude, longitude, "OPEN_METEO_UNAVAILABLE");
    }
  }
}

function baseSnapshot(
  enabled: boolean,
  status: WeatherSnapshot["status"],
  latitude: number | null,
  longitude: number | null,
  errorCode: string | null = null
): WeatherSnapshot {
  return {
    enabled,
    status,
    provider: null,
    latitude,
    longitude,
    timezone: "Asia/Taipei",
    current: null,
    errorCode
  };
}

function normalizeCurrentWeather(current: Record<string, unknown>) {
  return {
    time: typeof current.time === "string" ? current.time : null,
    temperature2m: numberOrNull(current.temperature_2m),
    relativeHumidity2m: numberOrNull(current.relative_humidity_2m),
    apparentTemperature: numberOrNull(current.apparent_temperature),
    precipitation: numberOrNull(current.precipitation),
    weatherCode: numberOrNull(current.weather_code),
    windSpeed10m: numberOrNull(current.wind_speed_10m)
  };
}

function numberOrNull(value: unknown) {
  return typeof value === "number" ? value : null;
}
