"use client";

import React, { useState, useEffect } from "react";
import UserTable from "./UserTable";
import UserProfile from "./UserProfile";
import EmailEditor from "./EmailEditor";
import { getUserManagementData } from "@/services/user_management";
import { User } from "./types";

const UserManagement: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [isEmailEditorOpen, setIsEmailEditorOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchUsers() {
      try {
        const data = await getUserManagementData();
        console.log("Fetched users:", data);

        const transformedUsers: User[] = data.map((user: any) => ({
          id: user.id,
          name: user.name,
          email: user.email,
          joined: user.joined,
          completionRate: user.completionRate,
          profilePicture: user.profilePicture,
          isActive: user.isActive,
          goodHabits: user.goodHabits,
          badHabits: user.badHabits,
          screenTime: user.screenTime,
          tasks: {
            completed: user.tasks.completed,
            pending: user.tasks.pending,
          },
        }));

        setUsers(transformedUsers);
      } catch (err: any) {
        console.error("Error fetching users:", err);
        setError(err.message || "Failed to load users");
      } finally {
        setLoading(false);
      }
    }

    fetchUsers();
  }, []);

  const handleUserSelect = (user: User) => {
    setSelectedUser(user);
  };

  const handleSendEmail = () => {
    setIsEmailEditorOpen(true);
  };

  if (loading) return <div className="p-6">Loading users...</div>;
  if (error) return <div className="p-6 text-red-500">{error}</div>;
  if (!users.length) return <div className="p-6">No users found.</div>;

  return (
    <div className="p-6">
      {!selectedUser ? (
        <UserTable users={users} onSelectUser={handleUserSelect} />
      ) : (
        <UserProfile user={selectedUser} onSendEmail={handleSendEmail} />
      )}

      {/* Updated EmailEditor with user email passed */}
      {isEmailEditorOpen && selectedUser && (
        <EmailEditor
          onClose={() => setIsEmailEditorOpen(false)}
          email={selectedUser.email}
        />
      )}
    </div>
  );
};

export default UserManagement;
