"use client";

import { useEffect, useState } from "react";
import { TrendingUpIcon } from "@/assets/icons";
import { compactFormat } from "@/lib/format-number";
import { cn } from "@/lib/utils";
import { getCampaignVisitorsData } from "@/services/charts.services";
import { CampaignVisitorsChart } from "./chart";

interface VisitorData {
  total_visitors: number;
  performance: number;
  chart: any[]; 
}

export function CampaignVisitors({ className }: { className?: string }) {
  const [data, setData] = useState<VisitorData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        const res = await getCampaignVisitorsData();
        setData(res);
      } catch (err: any) {
        console.error("Error fetching campaign visitor data:", err);
        setError("Failed to load data.");
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  return (
    <div
      className={cn(
        "rounded-[10px] bg-white shadow-1 dark:bg-gray-dark dark:shadow-card",
        className,
      )}
    >
      <div className="border-b border-stroke px-6 py-5.5 dark:border-dark-3">
        <div className="flex justify-between">
          <h2 className="mb-1.5 text-2xl font-bold text-dark dark:text-white">
            Active users
          </h2>

          <div className="mb-0.5 text-2xl font-bold text-dark dark:text-white">
            {loading ? "Loading..." : error ? "N/A" : compactFormat(data!.total_visitors)}
          </div>
        </div>

        <div className="flex justify-between">
          {loading ? (
            <span className="text-sm text-gray-500">Loading...</span>
          ) : error ? (
            <span className="text-sm text-red-500">{error}</span>
          ) : (
            <div
              className={cn(
                "flex items-center gap-1.5",
                data!.performance > 0 ? "text-green" : "text-red",
              )}
            >
              <TrendingUpIcon
                className={`${
                  data!.performance > 0 ? "-rotate-6" : "scale-y-[-1]"
                }`}
              />
              <span className="text-sm font-medium">{data!.performance}%</span>
            </div>
          )}
        </div>
      </div>

      {loading ? (
        <div className="p-6 text-center text-sm text-gray-500">Loading chart...</div>
      ) : error ? (
        <div className="p-6 text-center text-sm text-red-500">{error}</div>
      ) : (
        <CampaignVisitorsChart data={data!.chart} />
      )}
    </div>
  );
}
