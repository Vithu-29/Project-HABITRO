import React from "react";
import { suspendUserById } from "@/services/user_management";

interface Props {
  onSendEmail: () => void;
  userId: number;  // Accept userId to suspend
}

const UserActions: React.FC<Props> = ({ onSendEmail, userId }) => {
  const handleSuspend = async () => {
    if (!confirm("Are you sure you want to suspend this user?")) return;
    try {
      await suspendUserById(userId);
      alert("User suspended successfully!");
      window.location.reload(); // Reload to refresh table
    } catch (error) {
      console.error(error);
      alert("Failed to suspend user.");
    }
  };

  return (
    <div className="mt-4 flex gap-4">
      <button className="bg-red-500 text-white px-4 py-2 rounded" onClick={handleSuspend}>
        Suspend User
      </button>
      <button className="bg-blue-500 text-white px-4 py-2 rounded" onClick={onSendEmail}>
        Send Email
      </button>
      
    </div>    
  );
};

export default UserActions;
