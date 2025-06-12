"use client";

import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";
import { Input } from "@/components/ui/input";
import { Select, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import HabitTableOverview from "./HabitTableOverview";
import { getGoodHabitAnalytics } from "@/services/habit_management";

interface Habit {
  habitId: number;
  habitName: string;
  totalUsers: number;
  completedUsers: number;
}

export default function HabitTable() {
  const [search, setSearch] = useState("");
  const [duration, setDuration] = useState("Last Week");
  const [habits, setHabits] = useState<Habit[]>([]);
  const [selectedHabit, setSelectedHabit] = useState<Habit | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        const data = await getGoodHabitAnalytics();
        setHabits(data);
      } catch (err) {
        setError("Failed to load habit data.");
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  const filteredHabits = habits.filter((habit) =>
    habit.habitName.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-6 mt-4 bg-white shadow-md rounded-lg dark:bg-gray-dark">
      <div className="flex flex-wrap justify-between items-center mb-4 gap-4 text-dark dark:text-white dark:bg-gray-dark">
        <Input
          placeholder="Search habit..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-72 border rounded-md px-3 py-2"
        />

        <Select value={duration} onValueChange={setDuration} className="w-48">
          <SelectItem value="Last Week">Last Week</SelectItem>
          <SelectItem value="Last Month">Last Month</SelectItem>
          <SelectItem value="Last Year">Last Year</SelectItem>
        </Select>
      </div>

      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p className="text-red-500">{error}</p>
      ) : (
        <table className="w-full border-collapse bg-white rounded-lg overflow-hidden shadow-md text-dark dark:text-white dark:bg-gray-dark">
          <thead className="bg-gray-200 text-left dark:bg-gray-dark">
            <tr>
              <th className="p-3">Habit Name</th>
              <th className="p-3">Total Users</th>
              <th className="p-3">Completed Users</th>
              <th className="p-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredHabits.length > 0 ? (
              filteredHabits.map((habit) => (
                <tr key={habit.habitId} className="border-b">
                  <td className="p-3">{habit.habitName}</td>
                  <td className="p-3">{habit.totalUsers}</td>
                  <td className="p-3">{habit.completedUsers}</td>
                  <td className="p-3">
                    <Button className="dark:text-white" variant="outline" onClick={() => setSelectedHabit(habit)}>
                      View
                    </Button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={4} className="text-center p-3">
                  No habits found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      )}

      {selectedHabit && (
        <HabitTableOverview habit={selectedHabit} onClose={() => setSelectedHabit(null)} />
      )}
    </div>
  );
}