import React, { useState } from "react";
import { sendEmailToUser } from "@/services/user_management";

interface Props {
  onClose: () => void;
  email: string; // Accept email prop
}

const EmailEditor: React.FC<Props> = ({ onClose, email }) => {
  const [message, setMessage] = useState("");
  const [sending, setSending] = useState(false);

  const handleSend = async () => {
    try {
      setSending(true);
      await sendEmailToUser(email, "Message from Admin", message);
      alert("Email sent successfully!");
      onClose();
    } catch (error) {
      console.error(error);
      alert("Failed to send email.");
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50  dark:bg-gray-dark">
      <div className="bg-white p-6 rounded shadow w-1/2 dark:bg-gray-800">
        <h2 className="text-lg font-semibold">Send Email</h2>
        <textarea
          className="w-full border p-2 mt-2 "
          rows={6}
          placeholder="Write your message..."
          value={message}
          onChange={(e) => setMessage(e.target.value)}
        />
        <div className="mt-4 flex justify-end gap-2">
          <button className="bg-gray-500 text-white px-4 py-2 rounded" onClick={onClose}>Cancel</button>
          <button className="bg-green-500 text-white px-4 py-2 rounded" onClick={handleSend} disabled={sending}>
            {sending ? "Sending..." : "Send"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default EmailEditor;
