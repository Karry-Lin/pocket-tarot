export type TimeContext = {
  timezone: "Asia/Taipei";
  localDate: string;
  dayOfWeek: string;
  timeOfDay: "morning" | "afternoon" | "evening" | "night";
};

export function getTaipeiTimeContext(now = new Date()): TimeContext {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Taipei",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    weekday: "long",
    hour: "2-digit",
    hour12: false
  }).formatToParts(now);

  const value = (type: string) => parts.find((part) => part.type === type)?.value ?? "";
  const hour = Number(value("hour")) % 24;

  return {
    timezone: "Asia/Taipei",
    localDate: `${value("year")}-${value("month")}-${value("day")}`,
    dayOfWeek: value("weekday"),
    timeOfDay: getTimeOfDay(hour)
  };
}

function getTimeOfDay(hour: number): TimeContext["timeOfDay"] {
  if (hour >= 5 && hour <= 11) {
    return "morning";
  }

  if (hour >= 12 && hour <= 16) {
    return "afternoon";
  }

  if (hour >= 17 && hour <= 20) {
    return "evening";
  }

  return "night";
}
