
const PerformanceSettings = () => {
  const performanceData = {
    storage: 70,
    discSpace: 80,
    processor: 65,
    energyUsage: 50,
    networkUsage: 75,
  };

  return (
    <div className="p-4 border rounded-lg shadow bg-white dark:bg-gray-dark dark:shadow-card">
      <h2 className="text-xl font-bold mb-2">Performance Metrics</h2>
      {Object.entries(performanceData).map(([key, value]) => (
        <div key={key} className="mb-3">
          <label className="block capitalize mb-1">{key.replace(/([A-Z])/g, " $1")}</label>
          <progress
            value={value}
            max="100"
            className="w-full h-3 rounded-lg overflow-hidden appearance-none bg-gray-200 dark:bg-gray-700"
          />
          <div
            className="relative h-3 -mt-3 rounded-lg"
            style={{
              width: `${value}%`,
              backgroundColor: "blue",
            }}
          />
        </div>
      ))}
    </div>
  );
};

export default PerformanceSettings;
