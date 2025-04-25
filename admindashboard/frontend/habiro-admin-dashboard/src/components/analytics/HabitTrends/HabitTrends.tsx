"use client";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";

const data = [
  { habit: "Smoking", users: 50 },
  { habit: "Alcohol", users: 40 },
  { habit: "Screen Time", users: 70 },
  { habit: "Overeating", users: 30 },
];

const HabitTrends = () => {
  return (
    <div className="p-4 bg-white shadow rounded-xl  dark:bg-gray-dark dark:shadow-card">
      <h2 className="text-xl font-bold mb-4">Habit Trends</h2>
      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="habit" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Bar dataKey="users" fill="#10B981" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

export default HabitTrends;
