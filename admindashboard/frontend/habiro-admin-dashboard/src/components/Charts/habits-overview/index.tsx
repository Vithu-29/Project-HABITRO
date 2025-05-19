"use client";

import { useEffect, useState } from "react";
import { PeriodPicker } from "@/components/period-picker";
import { standardFormat } from "@/lib/format-number";
import { cn } from "@/lib/utils";
import { HabitOverviewChart } from "./chart";
import { getHabitOverview } from "@/services/habit_management";

type PropsType = {
  timeFrame?: string;
  className?: string;
};

export function HabitsOverview({ timeFrame = "daily", className }: PropsType) {
  const [data, setData] = useState<{ habitsCreated: any[]; habitsCompleted: any[] }>({
    habitsCreated: [],
    habitsCompleted: [],
  });

  useEffect(() => {
    async function fetchData() {
      const res = await getHabitOverview();
      setData(res);
    }
    fetchData();
  }, []);

  return (
    <div
      className={cn(
        "grid gap-2 rounded-[10px] bg-white px-7.5 pb-6 pt-7.5 shadow-1 dark:bg-gray-dark dark:shadow-card",
        className,
      )}
    >
      <div className="flex flex-wrap items-center justify-between gap-4">
        <h2 className="text-body-2xlg font-bold text-dark dark:text-white">Habit Overview</h2>
        <PeriodPicker defaultValue={timeFrame} sectionKey="habit_overview" />
      </div>

      <HabitOverviewChart data={data} />

      <dl className="grid divide-stroke text-center dark:divide-dark-3 sm:grid-cols-2 sm:divide-x [&>div]:flex [&>div]:flex-col-reverse [&>div]:gap-1">
        <div>
          <dt className="text-xl font-bold text-dark dark:text-white">
            {standardFormat(data.habitsCreated.reduce((acc, val) => acc + val.y, 0))}
          </dt>
          <dd className="font-medium dark:text-dark-6">Total Habits Created</dd>
        </div>
        <div>
          <dt className="text-xl font-bold text-dark dark:text-white">
            {standardFormat(data.habitsCompleted.reduce((acc, val) => acc + val.y, 0))}
          </dt>
          <dd className="font-medium dark:text-dark-6">Total Habits Completed</dd>
        </div>
      </dl>
    </div>
  );
}
