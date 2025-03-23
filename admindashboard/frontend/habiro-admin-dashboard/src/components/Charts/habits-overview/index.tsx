import { PeriodPicker } from "@/components/period-picker";
import { standardFormat } from "@/lib/format-number";
import { cn } from "@/lib/utils";
import {HabitOverviewChart} from "./chart";

type PropsType = {
  timeFrame?: string;
  className?: string;
};

// Default Data (Will be replaced by backend later)
const defaultData = {
  habitsCreated: [
    { x: "2025-03-10", y: 5 },
    { x: "2025-03-11", y: 7 },
    { x: "2025-03-12", y: 8 },
    { x: "2025-03-13", y: 6 },
    { x: "2025-03-14", y: 9 },
  ],
  habitsCompleted: [
    { x: "2025-03-10", y: 2 },
    { x: "2025-03-11", y: 5 },
    { x: "2025-03-12", y: 6 },
    { x: "2025-03-13", y: 4 },
    { x: "2025-03-14", y: 7 },
  ],
};

export async function HabitsOverview({
  timeFrame = "monthly",
  className,
}: PropsType) {
  // Replace with backend call later
  const data = defaultData;

  return (
    <div
      className={cn(
        "grid gap-2 rounded-[10px] bg-white px-7.5 pb-6 pt-7.5 shadow-1 dark:bg-gray-dark dark:shadow-card",
        className,
      )}
    >
      <div className="flex flex-wrap items-center justify-between gap-4">
        <h2 className="text-body-2xlg font-bold text-dark dark:text-white">
          Habit Overview
        </h2>

        <PeriodPicker defaultValue={timeFrame} sectionKey="habit_overview" />
      </div>

      <HabitOverviewChart data={data} />

      <dl className="grid divide-stroke text-center dark:divide-dark-3 sm:grid-cols-2 sm:divide-x [&>div]:flex [&>div]:flex-col-reverse [&>div]:gap-1">
        <div className="dark:border-dark-3 max-sm:mb-3 max-sm:border-b max-sm:pb-3">
          <dt className="text-xl font-bold text-dark dark:text-white">
            {standardFormat(
              data.habitsCreated.reduce((acc, { y }) => acc + y, 0),
            )}
          </dt>
          <dd className="font-medium dark:text-dark-6">Total Habits Created</dd>
        </div>

        <div>
          <dt className="text-xl font-bold text-dark dark:text-white">
            {standardFormat(
              data.habitsCompleted.reduce((acc, { y }) => acc + y, 0),
            )}
          </dt>
          <dd className="font-medium dark:text-dark-6">
            Total Habits Completed
          </dd>
        </div>
      </dl>
    </div>
  );
}
