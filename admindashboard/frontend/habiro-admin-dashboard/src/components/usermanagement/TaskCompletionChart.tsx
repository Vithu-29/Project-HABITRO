import React from "react";
import { Pie } from "react-chartjs-2";
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
} from "chart.js";


ChartJS.register(ArcElement, Tooltip, Legend);

const TaskCompletionChart: React.FC<{ completed: number; pending: number }> = ({
  completed,
  pending,
}) => {
  const data = {
    labels: ["Completed Tasks", "Pending Tasks"],
    datasets: [
      {
        data: [completed, pending],
        backgroundColor: ["#4CAF50", "#FF5733"],
      },
    ],
  };

  return (
    <div style={{ width: "300px", height: "300px" }}> {/* ✅ Fix chart size */}
      <Pie data={data} />
    </div>
  );
};

export default TaskCompletionChart;
