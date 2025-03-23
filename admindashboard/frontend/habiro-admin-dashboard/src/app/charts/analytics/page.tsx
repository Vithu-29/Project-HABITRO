"use client";
import { useState } from "react";
import AppUsage from "./AppUsage/AppUsage";
import HabitTrends from "./HabitTrends/HabitTrends";
import UserEngagement from "./UserEngagement/UserEngagement";

const AnalyticsPage = () => {
  const [selectedTab, setSelectedTab] = useState("AppUsage");

  return (
    <div className="p-6 bg-gray-100 min-h-screen">
      <h1 className="text-2xl font-bold mb-6">Analytics Dashboard</h1>

      {/* Navigation Bar */}
      <div className="flex space-x-4 mb-6">
        {["AppUsage", "HabitTrends", "UserEngagement"].map((tab) => (
          <button
            key={tab}
            onClick={() => setSelectedTab(tab)}
            className={`px-4 py-2 rounded-lg ${selectedTab === tab ? "bg-blue-600 text-white" : "bg-gray-300"
              }`}
          >
            {tab.replace(/([A-Z])/g, " $1").trim()}
          </button>
        ))}
      </div>

      {/* Content Rendering */}
      <div className="bg-white p-6 shadow-lg rounded-xl">
        {selectedTab === "AppUsage" && <AppUsage />}
        {selectedTab === "HabitTrends" && <HabitTrends />}
        {selectedTab === "UserEngagement" && <UserEngagement />}
      </div>
    </div>
  );
};

export default AnalyticsPage;
