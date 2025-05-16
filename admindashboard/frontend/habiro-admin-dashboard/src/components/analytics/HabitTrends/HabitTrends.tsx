import { useEffect, useState } from "react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import axios from "@/lib/axios";

const HabitTrends = () => {
  const [data, setData] = useState([]);

  useEffect(() => {
    axios.get("/analytics/habit-trends/")
      .then((res) => setData(res.data))
      .catch((err) => console.error("Habit Trends fetch error:", err));
  }, []);

  return (
    <div className="p-4 bg-white shadow rounded-xl dark:bg-gray-dark dark:shadow-card">
      <h2 className="text-xl font-bold mb-4">Habit Trends</h2>
      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="habit" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Bar dataKey="users" fill="#1f71d8" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

export default HabitTrends;
