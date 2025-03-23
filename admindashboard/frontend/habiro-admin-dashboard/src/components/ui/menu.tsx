"use client";

import { ReactNode, useState, useRef, useEffect } from "react";

interface MenuProps {
  children: ReactNode;
}

interface MenuItemProps {
  children: ReactNode;
  onClick?: () => void;
}

export function Menu({ children }: MenuProps) {
  const [open, setOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <div className="relative" ref={menuRef}>
      <div className="cursor-pointer" onClick={() => setOpen(!open)}>
        {children}
      </div>
      {open && (
        <div className="absolute right-0 mt-2 w-40 bg-white shadow-lg rounded-lg border p-2 z-50">
          {children}
        </div>
      )}
    </div>
  );
}

export function MenuItem({ children, onClick }: MenuItemProps) {
  return (
    <div
      className="px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded cursor-pointer"
      onClick={onClick}
    >
      {children}
    </div>
  );
}
