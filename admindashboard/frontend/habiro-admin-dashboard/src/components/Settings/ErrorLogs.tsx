"use client";
import { useState } from "react";

const ErrorLogs = () => {
  const [search, setSearch] = useState("");
  const errorLogs = [
    { id: 1, error: "Server timeout", status: "Pending", date: "2025-03-24", time: "10:45 AM" },
    { id: 2, error: "DB connection lost", status: "Solved", date: "2025-03-23", time: "3:15 PM" },
  ];

  return (
    <div className="p-4 border rounded-lg shadow bg-white  dark:bg-gray-dark dark:shadow-card">
      <h2 className="text-xl font-bold mb-2">Error Logs</h2>
      <input
        type="text"
        placeholder="Search..."
        className="border p-2 w-full mb-3"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />
      <table className="w-full border">
        <thead>
          <tr className="bg-gray-200  dark:bg-gray-dark dark:shadow-card">
            <th className="p-2">Error</th>
            <th className="p-2">Status</th>
            <th className="p-2">Date</th>
            <th className="p-2">Time</th>
          </tr>
        </thead>
        <tbody>
          {errorLogs
            .filter((log) => log.error.toLowerCase().includes(search.toLowerCase()))
            .map((log) => (
              <tr key={log.id} className="border-t">
                <td className="p-2">{log.error}</td>
                <td className="p-2">{log.status}</td>
                <td className="p-2">{log.date}</td>
                <td className="p-2">{log.time}</td>
              </tr>
            ))}
        </tbody>
      </table>
    </div>
  );
};

export default ErrorLogs;
