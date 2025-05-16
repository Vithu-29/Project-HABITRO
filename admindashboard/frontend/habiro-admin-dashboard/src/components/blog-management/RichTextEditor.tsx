"use client";

import React, { useState } from "react";
import dynamic from "next/dynamic";
import "react-quill/dist/quill.snow.css";

// Dynamically import ReactQuill to prevent SSR issues in Next.js
const ReactQuill = dynamic(() => import("react-quill"), { ssr: false });

interface RichTextEditorProps {
  onSend?: (content: string) => void; // Make `onSend` optional
}

const RichTextEditor: React.FC<RichTextEditorProps> = ({ onSend = () => {} }) => {
  const [content, setContent] = useState("");
  const [showSendButton, setShowSendButton] = useState(false);

  const handleChange = (value: string) => {
    setContent(value);
    setShowSendButton(value.trim().length > 0);
  };

  const handleSend = () => {
    if (content.trim()) {
      if (onSend) {
        onSend(content); // Call `onSend` only if it's provided
      }
      setContent(""); // Clear editor after sending
      setShowSendButton(false); // Hide button after sending
    }
  };

  return (
    <div className="bg-white p-4 shadow-lg rounded-lg relative h-[400px] dark:bg-gray-dark dark:shadow-card">
      <h2 className="text-xl font-semibold mb-2 dark:text-white">Write Your Blog Content</h2>
      <ReactQuill
        theme="snow"
        value={content}
        onChange={handleChange}
        modules={{
          toolbar: [
            [{ header: [1, 2, false] }],
            ["bold", "italic", "underline", "strike"],
            [{ list: "ordered" }, { list: "bullet" }],
            ["blockquote", "code-block"],
            [{ align: [] }],
            [{ color: [] }, { background: [] }],
            ["link", "image", "video"],
            ["clean"],
          ],
        }}
        formats={[
          "header",
          "bold",
          "italic",
          "underline",
          "strike",
          "list",
          "bullet",
          "blockquote",
          "code-block",
          "align",
          "color",
          "background",
          "link",
          "image",
          "video",
        ]}
        className="h-56"
      />
      {showSendButton && (
        <button
          onClick={handleSend}
          className="mt-4 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded transition absolute right-4 bottom-4"
        >
          Send
        </button>
      )}
    </div>
  );
};

export default RichTextEditor;
