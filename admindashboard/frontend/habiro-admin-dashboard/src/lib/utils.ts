import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * Utility function to merge Tailwind class names conditionally.
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Extracts a default time frame based on a given key.
 */
export const extractTimeFrame = (key: string): string | null => {
  const timeFrames: Record<string, string> = {
    payments_overview: "timeframe:monthly",
    user_activity: "timeframe:weekly",
    sales_report: "timeframe:daily",
    habit_tracking: "timeframe:monthly", // Added for habits
  };

  return timeFrames[key] ?? null;
};
