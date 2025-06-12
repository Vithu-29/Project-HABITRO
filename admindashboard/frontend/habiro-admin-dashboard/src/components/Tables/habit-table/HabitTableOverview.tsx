"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { getCompletedUsersByHabit } from "@/services/habit_management";

interface Habit {
  habitId: number;
  habitName: string;
}

interface User {
  id: number;
  name: string;
  email: string;
}

interface HabitTableOverviewProps {
  habit: Habit;
  onClose: () => void;
}

export default function HabitTableOverview({ habit, onClose }: HabitTableOverviewProps) {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchUsers() {
      try {
        const data = await getCompletedUsersByHabit(habit.habitId);
        setUsers(data);
      } catch (err: any) {
        setError("Failed to fetch users.");
      } finally {
        setLoading(false);
      }
    }
    fetchUsers();
  }, [habit.habitId]);

  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      onClick={onClose}
    >
      <div
        className="bg-white p-6 rounded-lg shadow-lg w-96 max-h-[80vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 className="text-xl font-bold mb-4">
          Users who completed {habit.habitName}
        </h2>

        {loading ? (
          <p>Loading...</p>
        ) : error ? (
          <p className="text-red-500">{error}</p>
        ) : (
          <ul className="divide-y max-h-60 overflow-y-auto pr-2">
            {users.map((user) => (
              <li key={user.id} className="py-2 flex flex-col">
                <span className="font-medium">{user.name}</span>
                <span className="text-sm text-gray-500">{user.email}</span>
              </li>
            ))}
          </ul>
        )}

        <div className="mt-4 text-right">
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
        </div>
      </div>
    </div>
  );
}