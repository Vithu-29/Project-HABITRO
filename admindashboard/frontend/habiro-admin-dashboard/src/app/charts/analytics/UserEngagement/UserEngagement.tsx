"use client";
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { motion } from "framer-motion";

const data = [
  { name: "Highly Engaged", value: 60 },
  { name: "Moderately Engaged", value: 30 },
  { name: "Low Engagement", value: 10 },
];

const COLORS = ["#4F46E5", "#FACC15", "#F43F5E"];

const UserEngagement = () => {
  return (
    <motion.div
      className="p-6 bg-white shadow-lg rounded-2xl"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <h2 className="text-2xl font-semibold text-gray-700 text-center mb-4">
        📊 User Engagement
      </h2>
      <ResponsiveContainer width="100%" height={350}>
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            innerRadius={70} // Donut effect
            outerRadius={110}
            fill="#8884d8"
            dataKey="value"
            label={({ name, percent }) => `${name} (${(percent * 100).toFixed(0)}%)`}
            lablStyle={{ fontSize: "14px", fontWeight: "bold" }}
            isAnimationActive
          >
            {data.map((entry, index) => (
              <Cell
                key={`cell-${index}`}
                fill={COLORS[index]}
                stroke="#ffffff"
                strokeWidth={2}
                className="hover:scale-110 transition-transform duration-200"
              />
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
