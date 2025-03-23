import React from "react";
import { cn } from "@/lib/utils";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  variant?: "default" | "outline" | "ghost" | "destructive";
  className?: string;
}

export const Button: React.FC<ButtonProps> = ({ children, variant = "default", className, ...props }) => {
  const buttonVariants = {
    default: "bg-blue-600 text-white hover:bg-blue-700",
    outline: "border border-gray-300 text-gray-700 hover:bg-gray-100",
    ghost: "text-gray-700 hover:bg-gray-100",
    destructive: "bg-red-600 text-white hover:bg-red-700",
  };

  return (
    <button
      className={cn(
        "px-4 py-2 rounded-lg transition font-medium",
        buttonVariants[variant],
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
};
