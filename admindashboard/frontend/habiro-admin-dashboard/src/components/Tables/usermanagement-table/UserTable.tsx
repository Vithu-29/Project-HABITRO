// UserTable.tsx
import React, { useState } from "react";
import { User } from "../../usermanagement/types";

interface UserTableProps {
  users: User[];
  onSelectUser: (user: User) => void;
}

const UserTable: React.FC<UserTableProps> = ({ users, onSelectUser }) => {
  const [searchTerm, setSearchTerm] = useState("");

  const filteredUsers = users.filter((user) =>
    user.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="p-6 mt-4 bg-white shadow-md rounded-lg dark:bg-gray-dark">

      <div>
        <input
          type="text"
          placeholder="Search users..."
          className="border  p-2 mb-4 w-full bg-gray-100"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />

        <table className="w-full border-collapse bg-white rounded-lg overflow-hidden shadow-md text-dark dark:text-white dark:bg-gray-dark">
          <thead>
            <tr className="bg-gray-400 text-white dark:text-white dark:bg-gray-dark">
              <th className="p-2 border">Profile</th>
              <th className="p-2 border">Name</th>
              <th className="p-2 border">Email</th>
              <th className="p-2 border">Joined Date</th>
              <th className="p-2 border">Completion Rate</th>
            </tr>
          </thead>
          <tbody >
            {filteredUsers.map((user) => (
              <tr key={user.id} className="cursor-pointer hover:bg-gray-10 hover:bg-gray-100/50" onClick={() => onSelectUser(user)}>
                <td className="p-2 border">
                  <img src={user.profilePicture} alt={user.name} className="w-10 h-10 rounded-full" />
                </td>
                <td className="p-2 border">{user.name}</td>
                <td className="p-2 border">{user.email}</td>
                <td className="p-2 border">{user.joined}</td>
                <td className="p-2 border">{user.completionRate}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default UserTable;
