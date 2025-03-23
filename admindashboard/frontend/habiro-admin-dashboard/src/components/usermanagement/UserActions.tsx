import React from "react";

interface Props {
  onSendEmail: () => void;
}

const UserActions: React.FC<Props> = ({ onSendEmail }) => {
  return (
    <div className="mt-4 flex gap-4">
      <button className="bg-red-500 text-white px-4 py-2 rounded">Suspend User</button>
      <button className="bg-blue-500 text-white px-4 py-2 rounded" onClick={onSendEmail}>
        Send Email
      </button>
    </div>
  );
};

export default UserActions;
