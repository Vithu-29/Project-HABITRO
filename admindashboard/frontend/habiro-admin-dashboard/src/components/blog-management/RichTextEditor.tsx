"use client";

import React, { useState } from "react";
import dynamic from "next/dynamic";
import "react-quill/dist/quill.snow.css";

const ReactQuill = dynamic(() => import("react-quill"), { ssr: false });

interface RichTextEditorProps {
  onSend?: (data: {
    title: string;
    category: string;
    content: string;
    image: File | null;
  }) => void;
}

const RichTextEditor: React.FC<RichTextEditorProps> = ({ onSend = () => {} }) => {
  const [content, setContent] = useState("");
  const [title, setTitle] = useState("");
  const [category, setCategory] = useState("Personal Development");
  const [image, setImage] = useState<File | null>(null);
  const [showSendButton, setShowSendButton] = useState(false);

  const handleSend = () => {
    if (title.trim() && content.trim()) {
      onSend({ title, category, content, image });
      setContent("");
      setTitle("");
      setCategory("Personal Development");
      setImage(null);
      setShowSendButton(false);
    }
  };

  return (
    <div className="bg-white p-5 h-[570px] shadow-lg rounded-lg dark:bg-gray-dark dark:shadow-card">
      <h2 className="text-xl font-semibold mb-2 dark:text-white">Write Your Blog Content</h2>
      <input
        type="text"
        placeholder="Enter Blog Title"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        className="w-full p-2 border rounded mb-3 dark:bg-gray-800 dark:text-white"
      />

      <select
        value={category}
        onChange={(e) => setCategory(e.target.value)}
        className="w-full p-2 border rounded mb-3 dark:bg-gray-800 dark:text-white"
      >
        <option>Personal Development</option>
        <option>Productivity</option>
        <option>Technology</option>
        <option>Health and Fitness</option>
        <option>Mental Well-Being</option>
      </select>

      <input
        type="file"
        accept="image/*"
        onChange={(e) => setImage(e.target.files?.[0] || null)}
        className="mb-4"
      />

      <ReactQuill
        theme="snow"
        value={content}
        onChange={(value) => {
          setContent(value);
          setShowSendButton(value.trim().length > 0);
        }}
        className="h-56"
      />

      {showSendButton && (
        <button
          onClick={handleSend}
          className="mt-5 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded absolute right-27 bottom-4"
        >
          Send
        </button>
      )}
    </div>
  );
};

export default RichTextEditor;
