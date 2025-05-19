import { compactFormat } from "@/lib/format-number";
import { getOverviewData } from "./fetch";
import { OverviewCard } from "./card";
import * as icons from "./icons";

export async function OverviewCardsGroup() {
  try {
    const { total_users, active_time, total_task, active_users } = await getOverviewData();

    return (
      <div className="grid gap-4 sm:grid-cols-2 sm:gap-6 xl:grid-cols-4 2xl:gap-7.5">
        <OverviewCard
          label="Total users"
          data={{
            ...total_users,
            value: compactFormat(total_users.value),
          }}
          Icon={icons.Users}
        />

        <OverviewCard
          label="Avarage active time"
          data={{
            ...active_time,
            value: "" + compactFormat(active_time.value),
          }}
          Icon={icons.ClockIcon}
        />

        <OverviewCard
          label="Total task"
          data={{
            ...total_task,
            value: compactFormat(total_task.value),
          }}
          Icon={icons.Product}
        />

        <OverviewCard
          label="Active Users"
          data={{
            ...active_users,
            value: compactFormat(active_users.value),
          }}
          Icon={icons.Views}
        />
      </div>
    );
  } catch (error) {
    console.error("Failed to render OverviewCardsGroup:", error);
    return (
      <div className="text-red-600">
        Failed to load overview data. Please try again later.
      </div>
    );
  }
}
