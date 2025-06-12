import NotificationSettings from "@/components/Settings/NotificationSettings";
import GamificationSettings from "@/components/Settings/GamificationSettings";
import ThemeSettings from "@/components/Settings/ThemeSettings";
import PerformanceSettings from "@/components/Settings/PerformanceSettings";
import ErrorLogs from "@/components/Settings/ErrorLogs";

export default function SettingsPage() {
  return (
    <div className="p-6 space-y-6  bg-white rounded-md  dark:bg-gray-dark dark:shadow-card">
      <NotificationSettings />
      <GamificationSettings />
      <ThemeSettings />
      <PerformanceSettings />
      <ErrorLogs />
    </div>
  );
}
