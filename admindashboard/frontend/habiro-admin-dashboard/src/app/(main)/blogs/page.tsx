"use client";

import { useState, useEffect } from "react";
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { PlusCircle } from "lucide-react";
import RichTextEditor from "../../../components/blog-management/RichTextEditor";
import "@/components/blog-management/RichTextEditor.css";

interface Article {
  title: string;
  category: string;
  content: string;
  date: string;
  views: number;
  image?: string;
}

export default function BlogManagement() {
  const [showEditor, setShowEditor] = useState(false);
  const [articles, setArticles] = useState<Article[]>([]);

  const fetchArticles = async () => {
    try {
      const res = await fetch("http://localhost:8000/api/articles/");
      const data = await res.json();
      setArticles(data);
    } catch (error) {
      console.error("Failed to fetch articles:", error);
    }
  };

  useEffect(() => {
    fetchArticles();
  }, []);

  const handleSend = async ({
    title,
    category,
    content,
    image,
  }: {
    title: string;
    category: string;
    content: string;
    image: File | null;
  }) => {
    const formData = new FormData();
    formData.append("title", title.trim());
    formData.append("category", category.trim());
    formData.append("content", content);

    if (image) {
      formData.append("image", image);
    }

    try {
      const response = await fetch("http://localhost:8000/api/articles/", {
        method: "POST",
        body: formData,
      }); 

      const resData = await response.json();

      if (response.ok) {
        alert("Blog submitted successfully!");
        setShowEditor(false);
        fetchArticles(); // refresh blog list
      } else {
        console.error("Backend error:", resData);
        alert(`Error: ${JSON.stringify(resData)}`);
      }
    } catch (error) {
      console.error("Submission error:", error);
      alert("Submission failed.");
    }
  };

  return (
    <div className="p-6 bg-gray-100 min-h-screen dark:bg-gray-dark dark:shadow-card">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800 dark:text-white">Blog Management</h1>
        <Button
          onClick={() => setShowEditor(true)}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg"
        >
          <PlusCircle className="w-5 h-5" />
          Add New Blog
        </Button>
      </div>

      {showEditor && (
        <div className="bg-white p-4 rounded-lg shadow-md mb-6 h-[700px] dark:bg-gray-dark dark:shadow-card">
          <RichTextEditor onSend={handleSend} />
          <Button
            onClick={() => setShowEditor(false)}
            className="mt-4 bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg"
          >
            Close Editor
          </Button>
        </div>
      )}

      <div className="bg-white shadow-md rounded-lg overflow-hidden dark:bg-gray-dark dark:shadow-card">
        <Table>
          <TableHeader>
            <TableRow className="bg-gray-200 dark:bg-gray-dark">
              <TableHead>Title</TableHead>
              <TableHead>Category</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Views</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {articles.map((article, index) => (
              <TableRow key={index} className="hover:bg-gray-100 transition">
                <TableCell>{article.title}</TableCell>
                <TableCell>{article.category}</TableCell>
                <TableCell>{new Date(article.date).toLocaleDateString()}</TableCell>
                <TableCell>{article.views.toLocaleString()}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
