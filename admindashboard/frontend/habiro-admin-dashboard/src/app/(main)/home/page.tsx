import { UsedDevices } from "@/components/Charts/used-devices";
import { RecentUsers } from "@/components/Tables/recent-user";
import { createTimeFrameExtractor } from "@/utils/timeframe-extractor";
import { Suspense } from "react";
import { OverviewCardsGroup } from "../../../components/overview-cards";
import { OverviewCardsSkeleton } from "../../../components/overview-cards/skeleton";
import AuthWrapper from '@/components/AuthProvider';
import { CampaignVisitors } from "@/components/Charts/active-user";
type PropsType = {
  searchParams: Promise<{
    selected_time_frame?: string;
  }>;
};

export default async function Home({ searchParams }: PropsType) {
  const { selected_time_frame } = await searchParams;
  const extractTimeFrame = createTimeFrameExtractor(selected_time_frame);

  return (
    <AuthWrapper>

      <Suspense fallback={<OverviewCardsSkeleton />}>
        <OverviewCardsGroup />
      </Suspense>


      <div className=" w-full mt-4 grid grid-cols-12 gap-4 md:mt-6 md:gap-6 2xl:mt-9 2xl:gap-7.5">
        <div className=" col-span-12 xl:col-span-5">
          <CampaignVisitors className="h-[500px] " />
        </div>
        <UsedDevices
          className="col-span-12 xl:col-span-7"
          key={extractTimeFrame("used_devices")}
          timeFrame={extractTimeFrame("used_devices")?.split(":")[1]}
        />
        <div className=" col-span-12 grid xl:col-span-12">
          <RecentUsers />
        </div>


      </div>

    </AuthWrapper>
  );
}
