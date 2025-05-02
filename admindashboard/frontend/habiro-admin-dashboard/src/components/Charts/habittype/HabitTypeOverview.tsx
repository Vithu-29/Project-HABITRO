"use client";

import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";
import { HabitTypeChart } from "./HabitTypeChart";
import { getHabitTypeOverview } from "@/services/habit_management";

type PropsType = {
  className?: string;
};

export function HabitTypeOverview({ className }: PropsType) {
  const [data, setData] = useState({ goodHabits: 0, badHabits: 0 });

  useEffect(() => {
    async function fetchData() {
      const res = await getHabitTypeOverview();
      setData(res);
    }
    fetchData();
  }, []);

  return (
    <div
      className={cn(
        "w-[600px] grid gap-2 rounded-[10px] bg-white px-7.5 pb-6 pt-7.5 shadow-1 dark:bg-gray-dark dark:shadow-card",
        className,
      )}
    >
      <HabitTypeChart data={data} />
    </div>
  );
}
