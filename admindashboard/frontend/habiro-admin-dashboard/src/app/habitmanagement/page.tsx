import React from "react";
import { HabitsOverview } from "@/components/Charts/habits-overview";
import { extractTimeFrame } from "@/lib/utils";
import { HabitTypeOverview } from "@/components/Charts/habittype/HabitTypeOverview";
import HabitTable  from "@/components/Tables/habit-table/HabitTable";

export default function HabitManagement() {

    return (
        <>
            <HabitsOverview
          className="col-span-12 xl:col-span-7"
          key={extractTimeFrame("payments_overview")}
          timeFrame={extractTimeFrame("payments_overview")?.split(":")[1]}
       
        />
         <HabitTypeOverview className="w-full mt-4 col-span-12 xl:col-span-5 " />
        <HabitTable  />
        </>

    );
}