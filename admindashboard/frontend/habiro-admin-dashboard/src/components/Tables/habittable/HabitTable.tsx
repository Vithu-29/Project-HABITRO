"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";
import { Input } from "@/components/ui/input";
import { Select, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import HabitTableOverview from "./HabitTableOverview";

const defaultHabits = [
  { id: 1, name: "Exercise", totalUsers: 50, completedUsers: 35 },
  { id: 2, name: "Reading", totalUsers: 40, completedUsers: 25 },
  { id: 3, name: "Meditation", totalUsers: 30, completedUsers: 18 },
  { id: 4, name: "Junk Food Avoidance", totalUsers: 20, completedUsers: 10 },
  { id: 5, name: "Early Waking", totalUsers: 35, completedUsers: 28 },
  { id: 6, name: "Social Media Detox", totalUsers: 45, completedUsers: 30 },
  { id: 7, name: "Daily Journaling", totalUsers: 25, completedUsers: 15 },
  { id: 8, name: "Hydration", totalUsers: 50, completedUsers: 40 },
  { id: 9, name: "Stretching", totalUsers: 30, completedUsers: 22 },
  { id: 10, name: "Screen Time Limit", totalUsers: 40, completedUsers: 27 },
];

export default function HabitTable() {
  const [search, setSearch] = useState("");
  const [duration, setDuration] = useState("Last Week");
  const [selectedHabit, setSelectedHabit] = useState(null);

  const filteredHabits = defaultHabits.filter((habit) =>
    habit.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-6 mt-4 bg-white shadow-md rounded-lg dark:bg-gray-dark">
      <div className="flex flex-wrap justify-between items-center mb-4 gap-4  text-dark dark:text-white dark:bg-gray-dark">
        {/* Search Input */}
        <Input
          placeholder="Search habit..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-72 border rounded-md px-3 py-2"
        />

        {/* Duration Selector */}
        <Select value={duration} onValueChange={setDuration} className="w-48">
          <SelectItem value="Last Week">Last Week</SelectItem>
          <SelectItem value="Last Month">Last Month</SelectItem>
          <SelectItem value="Last Year">Last Year</SelectItem>
        </Select>
      </div>

      {/* Habit Table */}
      <table className="w-full border-collapse bg-white rounded-lg overflow-hidden shadow-md  text-dark dark:text-white dark:bg-gray-dark">
        <thead className="bg-gray-200 text-left  text-dark dark:text-white dark:bg-gray-dark">
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
              <tr key={habit.id} className="border-b">
                <td className="p-3">{habit.name}</td>
                <td className="p-3">{habit.totalUsers}</td>
                <td className="p-3">{habit.completedUsers}</td>
                <td className="p-3">
                  <Button
                    variant="outline"
                    onClick={() => setSelectedHabit(habit)}
                  >
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

      {/* Show Habit Users Modal */}
      {selectedHabit && (
        <HabitTableOverview habit={selectedHabit} onClose={() => setSelectedHabit(null)} />
      )}
    </div>
  );
}
