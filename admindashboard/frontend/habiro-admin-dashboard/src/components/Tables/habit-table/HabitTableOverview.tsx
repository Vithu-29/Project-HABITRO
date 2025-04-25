"use client";

import { Button } from "@/components/ui/button";

interface Habit {
  id: number;
  name: string;
}

interface HabitTableOverviewProps {
  habit: Habit;
  onClose: () => void;
}

const defaultUsers = [
  { id: 1, name: "John Doe", status: "Completed" },
  { id: 2, name: "Jane Smith", status: "Not Completed" },
  { id: 3, name: "Alice Brown", status: "Completed" },
  { id: 4, name: "Mark Wilson", status: "Completed" },
  { id: 5, name: "Emma Johnson", status: "Not Completed" },
];

export default function HabitTableOverview({ habit, onClose }: HabitTableOverviewProps) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div className="bg-white p-6 rounded-lg shadow-lg w-96">
        <h2 className="text-xl font-bold mb-4">Users for {habit?.name}</h2>

        {/* User List */}
        <ul className="divide-y">
          {defaultUsers.map((user) => (
            <li key={user.id} className="py-2 flex justify-between">
              <span>{user.name}</span>
              <span
                className={`px-2 py-1 rounded text-white ${
                  user.status === "Completed" ? "bg-green-500" : "bg-red-500"
                }`}
              >
                {user.status}
              </span>
            </li>
          ))}
        </ul>

        {/* Close Button */}
        <div className="mt-4 text-right">
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
        </div>
      </div>
    </div>
  );
}
