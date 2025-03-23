import { cn } from "@/lib/utils";
import { HabitTypeChart } from "./HabitTypeChart";

type PropsType = {
  className?: string;
};

// Default Data (Replace with backend data later)
const defaultData = {
  goodHabits: 60, // Example: 60 good habits
  badHabits: 40,  // Example: 40 bad habits
};

export function HabitTypeOverview({ className }: PropsType) {
  // Replace with backend API call later
  const data = defaultData;

  return (
    <div
      className={cn(
        "w-[600px]  grid gap-2 rounded-[10px] bg-white px-7.5 pb-6 pt-7.5 shadow-1 dark:bg-gray-dark dark:shadow-card",
        className,
      )}
    >
      <HabitTypeChart data={data} />
    </div>
  );
}
