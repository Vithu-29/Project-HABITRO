"use client";
import { useState } from "react";

const NotificationSettings = () => {
  const [settings, setSettings] = useState({
    emailNotifications: false,
    updateNotifications: false,
    navbarNotifications: false,
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, checked } = e.target;
    setSettings((prev) => ({ ...prev, [name]: checked }));
  };

  const saveSettings = async () => {
    await fetch("/api/settings/notifications", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(settings),
    });
  };

  return (
    <div className="p-4 border rounded-lg shadow  bg-white  dark:bg-gray-dark dark:shadow-card space-y-3">
      <h2 className="text-xl font-bold mb-2">Notification Settings</h2>
      <label className="block">
        <input type="checkbox" name="emailNotifications" checked={settings.emailNotifications} onChange={handleChange} />
        Allow notifications via email
      </label>
      <label className="block">
        <input type="checkbox" name="updateNotifications" checked={settings.updateNotifications} onChange={handleChange} />
        Allow update notifications via email
      </label>
      <label className="block">
        <input type="checkbox" name="navbarNotifications" checked={settings.navbarNotifications} onChange={handleChange} />
        Show notifications on the navigation bar
      </label>
      <button className="mt-3 px-4 py-2 bg-blue-600 text-white rounded" onClick={saveSettings}>
        Save
      </button>
    </div>
  );
};

export default NotificationSettings;
