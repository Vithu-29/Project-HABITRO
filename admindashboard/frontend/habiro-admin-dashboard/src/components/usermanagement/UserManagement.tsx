// UserManagement.tsx
import React, { useState } from "react";
import UserTable from "./UserTable";
import UserProfile from "./UserProfile";
import EmailEditor from "./EmailEditor";
import usersData from "./usersData";
import { User } from "./types";

const UserManagement: React.FC = () => {
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [isEmailEditorOpen, setIsEmailEditorOpen] = useState(false);

  const handleUserSelect = (user: User) => {
    setSelectedUser(user);
  };

  const handleSendEmail = () => {
    setIsEmailEditorOpen(true);
  };

  return (
    <div className="p-6">
      {!selectedUser ? (
        <UserTable users={usersData} onSelectUser={handleUserSelect} />
      ) : (
        <UserProfile user={selectedUser} onSendEmail={handleSendEmail} />
      )}

      {isEmailEditorOpen && <EmailEditor onClose={() => setIsEmailEditorOpen(false)} />}
    </div>
  );
};

export default UserManagement;
