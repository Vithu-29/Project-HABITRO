"use client";
import { useState } from "react";
const GamificationSettings = () => {
  const [settings, setSettings] = useState({
    earnPoints: true,
    encouragements: true,
    milestones: true,
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, checked } = e.target;
    setSettings((prev) => ({ ...prev, [name]: checked }));
  };

  const saveSettings = async () => {
    await fetch("/api/settings/gamification", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(settings),
    });
  };

  return (
    <div className="p-4 border rounded-lg shadow bg-white  dark:bg-gray-dark dark:shadow-card space-y-3">
      <h2 className="text-xl font-bold mb-2">Gamification Settings</h2>
      <label className="block">
        <input type="checkbox" name="earnPoints" checked={settings.earnPoints} onChange={handleChange} />
        Enable earning points
      </label>
      <label className="block">
        <input type="checkbox" name="encouragements" checked={settings.encouragements} onChange={handleChange} />
        Enable encouragements
      </label>
      <label className="block">
        <input type="checkbox" name="milestones" checked={settings.milestones} onChange={handleChange} />
        Set milestones
      </label>
      <button className="mt-3 px-4 py-2 bg-blue-600 text-white rounded" onClick={saveSettings}>
        Save
      </button>
    </div>
  );
};

export default GamificationSettings;
