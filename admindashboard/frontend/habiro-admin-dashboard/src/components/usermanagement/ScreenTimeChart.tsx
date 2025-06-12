import React from "react";
import { Bar } from "react-chartjs-2";
import {
  Chart as ChartJS,
  BarElement,
  CategoryScale,
  LinearScale,
  Title,
  Tooltip,
  Legend,
} from "chart.js";

// Register required components
ChartJS.register(BarElement, CategoryScale, LinearScale, Title, Tooltip, Legend);

const ScreenTimeChart: React.FC<{ screenTime: number[] }> = ({ screenTime }) => {
  const data = {
    labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    datasets: [
  {
    label: "Screen Time (hours)",
    data: screenTime,
    backgroundColor: "#4bc0c0", 
    borderColor: "#4bc0c0",     
    borderWidth: 1,
  },
]

  };

  const options = {
    responsive: true,
    maintainAspectRatio: false, // Allows custom width & height
    scales: {
      y: {
        beginAtZero: true,
      },
    },
  };

  return (
    <div style={{ width: "400px", height: "250px" }}> {/* Fix chart size */}
      <Bar data={data} options={options} />
    </div>
  );
};

export default ScreenTimeChart;
