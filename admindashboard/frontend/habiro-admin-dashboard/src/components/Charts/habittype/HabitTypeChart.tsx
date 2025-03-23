"use client";

import dynamic from "next/dynamic";
import { ApexOptions } from "apexcharts";

type PropsType = {
  data: {
    goodHabits: number;
    badHabits: number;
  };
};

const Chart = dynamic(() => import("react-apexcharts"), {
  ssr: false,
});

export function HabitTypeChart({ data }: PropsType) {
  const options: ApexOptions = {
    labels: ["Good Habits", "Bad Habits"],
    colors: ["#34D399", "#F87171"], // Green for good, Red for bad
    chart: {
      type: "pie",
    },
    legend: {
      position: "bottom",
    },
    dataLabels: {
      enabled: true,
    },
  };

  return (
    <div className="flex flex-col items-center ">
      <h2 className="text-lg font-bold text-dark dark:text-white mb-4">
        Habit Type Overview
      </h2>
      <Chart options={options} series={[data.goodHabits, data.badHabits]} type="pie" height={300} />
    </div>
  );
}
