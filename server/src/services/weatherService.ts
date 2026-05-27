import type { WeatherSnapshot } from "../models/DailyReading.js";

export type WeatherInput = {
  enabled?: unknown;
  status?: unknown;
  latitude?: unknown;
  longitude?: unknown;
  locale?: unknown;
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
    const locale = input.locale === "en" ? "en" : "zh-TW";

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
        locationName: resolveTaiwanRegionName(latitude, longitude, locale),
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
    locationName: null,
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

type TaiwanRegion = {
  zhTw: string;
  en: string;
  latitude: number;
  longitude: number;
};

const taiwanRegions: TaiwanRegion[] = [
  { zhTw: "台北市", en: "Taipei City", latitude: 25.033, longitude: 121.5654 },
  { zhTw: "新北市", en: "New Taipei City", latitude: 25.0169, longitude: 121.4628 },
  { zhTw: "基隆市", en: "Keelung City", latitude: 25.1283, longitude: 121.7419 },
  { zhTw: "桃園市", en: "Taoyuan City", latitude: 24.9937, longitude: 121.3009 },
  { zhTw: "新竹市", en: "Hsinchu City", latitude: 24.8039, longitude: 120.9647 },
  { zhTw: "新竹縣", en: "Hsinchu County", latitude: 24.839, longitude: 121.004 },
  { zhTw: "苗栗縣", en: "Miaoli County", latitude: 24.5602, longitude: 120.8214 },
  { zhTw: "台中市", en: "Taichung City", latitude: 24.1477, longitude: 120.6736 },
  { zhTw: "彰化縣", en: "Changhua County", latitude: 24.0518, longitude: 120.5161 },
  { zhTw: "南投縣", en: "Nantou County", latitude: 23.9609, longitude: 120.9719 },
  { zhTw: "雲林縣", en: "Yunlin County", latitude: 23.7092, longitude: 120.4313 },
  { zhTw: "嘉義市", en: "Chiayi City", latitude: 23.4801, longitude: 120.4491 },
  { zhTw: "嘉義縣", en: "Chiayi County", latitude: 23.4518, longitude: 120.2555 },
  { zhTw: "台南市", en: "Tainan City", latitude: 22.9999, longitude: 120.227 },
  { zhTw: "高雄市", en: "Kaohsiung City", latitude: 22.6273, longitude: 120.3014 },
  { zhTw: "屏東縣", en: "Pingtung County", latitude: 22.5519, longitude: 120.5487 },
  { zhTw: "宜蘭縣", en: "Yilan County", latitude: 24.7021, longitude: 121.7378 },
  { zhTw: "花蓮縣", en: "Hualien County", latitude: 23.9872, longitude: 121.6015 },
  { zhTw: "台東縣", en: "Taitung County", latitude: 22.7583, longitude: 121.1444 },
  { zhTw: "澎湖縣", en: "Penghu County", latitude: 23.5711, longitude: 119.5793 },
  { zhTw: "金門縣", en: "Kinmen County", latitude: 24.4494, longitude: 118.3761 },
  { zhTw: "連江縣", en: "Lienchiang County", latitude: 26.1602, longitude: 119.9517 }
];

const maxTaiwanRegionDistanceKm = 90;
const earthRadiusKm = 6371;

export function resolveTaiwanRegionName(latitude: number, longitude: number, locale: "zh-TW" | "en") {
  let nearest: { region: TaiwanRegion; distanceKm: number } | null = null;

  for (const region of taiwanRegions) {
    const distanceKm = haversineKm(latitude, longitude, region.latitude, region.longitude);
    if (!nearest || distanceKm < nearest.distanceKm) {
      nearest = { region, distanceKm };
    }
  }

  if (!nearest || nearest.distanceKm > maxTaiwanRegionDistanceKm) {
    return null;
  }

  return locale === "en" ? nearest.region.en : nearest.region.zhTw;
}

function haversineKm(fromLatitude: number, fromLongitude: number, toLatitude: number, toLongitude: number) {
  const latitudeDelta = degreesToRadians(toLatitude - fromLatitude);
  const longitudeDelta = degreesToRadians(toLongitude - fromLongitude);
  const fromLatitudeRadians = degreesToRadians(fromLatitude);
  const toLatitudeRadians = degreesToRadians(toLatitude);
  const angle =
    Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(fromLatitudeRadians) * Math.cos(toLatitudeRadians) * Math.sin(longitudeDelta / 2) ** 2;

  return earthRadiusKm * 2 * Math.atan2(Math.sqrt(angle), Math.sqrt(1 - angle));
}

function degreesToRadians(value: number) {
  return (value * Math.PI) / 180;
}
