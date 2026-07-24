const DEFAULT_TIME_ZONE = "Europe/Warsaw";
const DEFAULT_LOCALE = "pl-PL";

export const APP_TIME_ZONE =
  process.env.NEXT_PUBLIC_TIME_ZONE ?? DEFAULT_TIME_ZONE;

const DEFAULT_DATE_TIME_OPTIONS: Intl.DateTimeFormatOptions = {
  dateStyle: "medium",
  timeStyle: "short",
};

export function formatDateTime(
  value: Date | string | number,
  options: Intl.DateTimeFormatOptions = DEFAULT_DATE_TIME_OPTIONS,
): string {
  return new Intl.DateTimeFormat(DEFAULT_LOCALE, {
    ...options,
    timeZone: APP_TIME_ZONE,
  }).format(new Date(value));
}
