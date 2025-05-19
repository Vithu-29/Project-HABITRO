import React from "react";
import ScreenTimeChart from "./ScreenTimeChart";
import TaskCompletionChart from "./TaskCompletionChart";
import UserActions from "./UserActions";
import { User } from "./types";

interface Props {
  user: User;
  onSendEmail: () => void;
}

const UserProfile: React.FC<Props> = ({ user, onSendEmail }) => {
  // Fallback image for profile picture
  const profilePic = user.profilePicture || "/default-avatar.png";

  // Utility to safely get array or return empty
  const safeArray = (arr?: string[]) => Array.isArray(arr) ? arr : [];

  // Validate chart data
  const isChartDataValid = Array.isArray(user.screenTime) && user.screenTime.length > 0;

  return (
    <div className="bg-white p-6 rounded shadow dark:bg-gray-dark dark:shadow-card">
      {/* Profile Info */}
      <div className="flex items-center">
        <img
          src={profilePic}
          alt={user.name || "User"}
          className="w-20 h-20 rounded-full mr-4 object-cover"
        />
        <div>
          <h2 className="text-xl font-bold">{user.name || "Unknown User"}</h2>
          <p className="text-gray-600">{user.email || "No email provided"}</p>
          <p>Joined: {user.joined || "N/A"}</p>
          <p>Completion Rate: {user.completionRate ?? "N/A"}</p>
          <p
            className={`mt-2 font-semibold ${
              user.isActive ? "text-green-600" : "text-red-600"
            }`}
          >
            Status: {user.isActive ? "Active" : "Inactive"}
          </p>
        </div>
      </div>

      {/* Charts Section */}
      <div className="flex w-full justify-between mt-6 flex-wrap gap-6">
        <div className="flex-1 min-w-[250px]">
          <h3 className="text-lg font-semibold">Daily Screen Time</h3>
          {isChartDataValid ? (
            <ScreenTimeChart screenTime={user.screenTime} />
          ) : (
            <p className="text-gray-500 mt-2">No screen time data available.</p>
          )}
        </div>
        <div className="flex-1 min-w-[250px] mr-10">
          <h3 className="text-lg font-semibold">Task Completion</h3>
          {user.tasks ? (
            <TaskCompletionChart
              completed={user.tasks.completed ?? 0}
              pending={user.tasks.pending ?? 0}
            />
          ) : (
            <p className="text-gray-500 mt-2">No task data available.</p>
          )}
        </div>
      </div>

      {/* Good & Bad Habits */}
      <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="p-4 bg-green-100 rounded-lg">
          <h3 className="text-lg font-semibold text-green-700">Good Habits</h3>
          {safeArray(user.goodHabits).length > 0 ? (
            <ul className="list-disc list-inside text-green-600">
              {safeArray(user.goodHabits).map((habit, index) => (
                <li key={index}>{habit}</li>
              ))}
            </ul>
          ) : (
            <p className="text-green-600">No good habits listed.</p>
          )}
        </div>

        <div className="p-4 bg-red-100 rounded-lg">
          <h3 className="text-lg font-semibold text-red-700">Bad Habits</h3>
          {safeArray(user.badHabits).length > 0 ? (
            <ul className="list-disc list-inside text-red-600">
              {safeArray(user.badHabits).map((habit, index) => (
                <li key={index}>{habit}</li>
              ))}
            </ul>
          ) : (
            <p className="text-red-600">No bad habits listed.</p>
          )}
        </div>
      </div>

      {/* User Actions */}
      {user.id ? (
        <UserActions onSendEmail={onSendEmail} userId={user.id} />
      ) : (
        <p className="mt-6 text-red-500">Unable to load user actions. Missing user ID.</p>
      )}
    </div>
  );
};

export default UserProfile;
