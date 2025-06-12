import React from "react";
import  {HabitsOverview}  from "@/components/Charts/habits-overview/index";
import { HabitTypeOverview } from "@/components/Charts/habittype/HabitTypeOverview";
import HabitTable from "@/components/Tables/habit-table/HabitTable";

export default function HabitManagement() {

    return (
        <>
            <HabitsOverview
                className="col-span-12 xl:col-span-7"

            />
            <HabitTypeOverview className="w-full mt-4 col-span-12 xl:col-span-5 " />
            <HabitTable />
        </>

    );
}