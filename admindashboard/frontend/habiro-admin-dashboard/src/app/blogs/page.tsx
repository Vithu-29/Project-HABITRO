"use client";

import { useState } from "react";
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { PlusCircle } from "lucide-react";
import RichTextEditor from "../../components/blog-management/RichTextEditor";
import "@/components/blog-management/RichTextEditor.css";
const blogs = [
  { name: "AI in Modern Life", date: "Mar 20, 2025", views: 1200, due: "Apr 15, 2025" },
  { name: "Next.js for Beginners", date: "Mar 18, 2025", views: 950, due: "Apr 10, 2025" },
  { name: "Cybersecurity Trends", date: "Mar 16, 2025", views: 800, due: "Apr 5, 2025" },
];

export default function BlogManagement() {
  const [showEditor, setShowEditor] = useState(false);

  return (
    <div className="p-6 bg-gray-100 min-h-screen  dark:bg-gray-dark dark:shadow-card">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800 dark:text-white  dark:bg-gray-dark dark:shadow-card">Blog Management</h1>
        <Button
          onClick={() => setShowEditor(true)}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg"
        >
          <PlusCircle className="w-5 h-5" />
          Add New Blog
        </Button>
      </div>

      {/* Show Rich Text Editor when button is clicked */}
      {showEditor && (
        <div className="bg-white p-4 rounded-lg shadow-md mb-6 h-[500px]">
          <RichTextEditor />
          <Button
            onClick={() => setShowEditor(false)}
            className="mt-4 bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg"
          >
            Close Editor
          </Button>
        </div>
      )}

      {/* Blog Table */}
      <div className="bg-white shadow-md rounded-lg overflow-hidden  dark:bg-gray-dark dark:shadow-card">
        <Table>
          <TableHeader>
            <TableRow className="bg-gray-200  dark:bg-gray-dark dark:shadow-card">
              <TableHead>Blog Name</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Views</TableHead>
              <TableHead>Due Date</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {blogs.map((blog, index) => (
              <TableRow key={index} className="hover:bg-gray-100 transition">
                <TableCell>{blog.name}</TableCell>
                <TableCell>{blog.date}</TableCell>
                <TableCell>{blog.views.toLocaleString()}</TableCell>
                <TableCell>{blog.due}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
