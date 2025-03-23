"use client";

import { useState } from "react";
import dynamic from "next/dynamic";
import "react-quill/dist/quill.snow.css";

const ReactQuill = dynamic(() => import("react-quill"), { ssr: false });

interface RichTextEditorProps {
  value?: string;
  onChange?: (content: string) => void;
}

const RichTextEditor = ({ value = "", onChange }: RichTextEditorProps) => {
  const modules = {
    toolbar: [
      [{ header: [1, 2, false] }],
      ["bold", "italic", "underline", "strike"],
      [{ list: "ordered" }, { list: "bullet" }],
      ["link", "image"],
      [{ align: [] }],
      ["clean"],
    ],
  };

  return (
    <div className="bg-white border rounded-md shadow-sm">
      <ReactQuill
        theme="snow"
        value={value}
        onChange={onChange || (() => {})}
        modules={modules}
        className="h-40"
      />
    </div>
  );
};

export default RichTextEditor; // ✅ Now it has a default export
