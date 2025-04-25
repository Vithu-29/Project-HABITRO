"use client";
import { useTheme } from "next-themes";

const ThemeSettings = () => {
  const { theme, setTheme } = useTheme();

  return (
    <div className="p-4 border rounded-lg shadow bg-white dark:bg-gray-dark dark:shadow-card">
      <h2 className="text-xl font-bold mb-2">Theme Settings</h2>
      <label className="flex items-center">
        <input
          type="checkbox"
          checked={theme === "dark"}
          onChange={() => setTheme(theme === "light" ? "dark" : "light")}
          className="mr-2"
        />
        <span>Enable Dark Mode</span>
      </label>
    </div>
  );
};

export default ThemeSettings;
