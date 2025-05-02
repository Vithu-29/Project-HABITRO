import { useEffect, useState } from "react";
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { motion } from "framer-motion";
import axios from "@/lib/axios";

const COLORS = ["#4F46E5", "#FACC15", "#F43F5E"];

const UserEngagement = () => {
  const [data, setData] = useState([]);

  useEffect(() => {
    axios.get("/analytics/user-engagement/")
      .then((res) => setData(res.data))
      .catch((err) => console.error("Engagement fetch error:", err));
  }, []);

  return (
    <motion.div
      className="p-6 bg-white shadow-lg rounded-2xl dark:bg-gray-dark dark:shadow-card"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <h2 className="text-2xl font-semibold text-center mb-4 dark:text-white"> User Engagement</h2>
      <ResponsiveContainer width="100%" height={350}>
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            innerRadius={70}
            outerRadius={110}
            fill="#8884d8"
            dataKey="value"
            label={({ name, percent }) => `${name} (${(percent * 100).toFixed(0)}%)`}
          >
            {data.map((entry, index) => (
              <Cell key={index} fill={COLORS[index % COLORS.length]} stroke="#fff" strokeWidth={2} />
            ))}
          </Pie>
          <Tooltip />
          <Legend />
        </PieChart>
      </ResponsiveContainer>
    </motion.div>
  );
};

export default UserEngagement;
