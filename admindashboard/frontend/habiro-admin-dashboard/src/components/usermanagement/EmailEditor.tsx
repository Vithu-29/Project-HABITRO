import React from "react";

interface Props {
  onClose: () => void;
}

const EmailEditor: React.FC<Props> = ({ onClose }) => {
  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-white p-6 rounded shadow w-1/2">
        <h2 className="text-lg font-semibold">Send Email</h2>
        <textarea className="w-full border p-2 mt-2" rows={6} placeholder="Write your message..."></textarea>
        <div className="mt-4 flex justify-end gap-2">
          <button className="bg-gray-500 text-white px-4 py-2 rounded" onClick={onClose}>Cancel</button>
          <button className="bg-green-500 text-white px-4 py-2 rounded">Send</button>
        </div>
      </div>
    </div>
  );
};

export default EmailEditor;
