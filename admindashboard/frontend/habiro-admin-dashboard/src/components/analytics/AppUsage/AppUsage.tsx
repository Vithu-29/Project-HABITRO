import { useEffect, useState } from "react";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import axios from "@/lib/axios";

const AppUsage = () => {
  const [data, setData] = useState([]);

  useEffect(() => {
    axios.get("/analytics/app-usage/")
      .then((res) => setData(res.data))
      .catch((err) => console.error("App Usage fetch error:", err));
  }, []);

  return (
    <div className="p-4 bg-white shadow rounded-xl dark:bg-gray-dark dark:shadow-card">
      <h2 className="text-xl font-bold mb-4">App Usage</h2>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="date" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Line type="monotone" dataKey="usage" stroke="#4F46E5" strokeWidth={3} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};

export default AppUsage;
