// UserProfile.tsx
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
  return (
    <div className="bg-white p-6 rounded shadow dark:bg-gray-dark dark:shadow-card">
      {/* Profile Info */}
      <div className="flex items-center">
        <img src={user.profilePicture} alt={user.name} className="w-20 h-20 rounded-full mr-4" />
        <div>
          <h2 className="text-xl font-bold">{user.name}</h2>
          <p className="text-gray-600">{user.email}</p>
          <p>Joined: {user.joined}</p>
          <p>Completion Rate: {user.completionRate}</p>
          <p className={`mt-2 font-semibold ${user.isActive ? "text-green-600" : "text-red-600"}`}>
            Status: {user.isActive ? "Active" : "Inactive"}
          </p>
        </div>
      </div>

      {/* Charts Section */}
      <div className="flex w-full justify-between mt-6">
        <div>
          <h3 className="text-lg font-semibold">Daily Screen Time</h3>
          <ScreenTimeChart screenTime={user.screenTime} />
        </div>
        <div className="mr-14">
          <h3 className="text-lg font-semibold">Task Completion</h3>
          <TaskCompletionChart completed={user.tasks.completed} pending={user.tasks.pending} />
        </div>
      </div>

      {/* Good & Bad Habits */}
      <div className="mt-6 grid grid-cols-2 gap-4">
        <div className="p-4 bg-green-100 rounded-lg">
          <h3 className="text-lg font-semibold text-green-700">Good Habits</h3>
          <ul className="list-disc list-inside text-green-600">
            {user.goodHabits.map((habit, index) => (
              <li key={index}>{habit}</li>
            ))}
          </ul>
        </div>

        <div className="p-4 bg-red-100 rounded-lg">
          <h3 className="text-lg font-semibold text-red-700">Bad Habits</h3>
          <ul className="list-disc list-inside text-red-600">
            {user.badHabits.map((habit, index) => (
              <li key={index}>{habit}</li>
            ))}
          </ul>
        </div>
      </div>

    <UserActions onSendEmail={onSendEmail} userId={user.id} />

    </div>
  );
};

export default UserProfile;
