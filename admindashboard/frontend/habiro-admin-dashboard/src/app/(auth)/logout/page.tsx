"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function LogoutPage() {
  const router = useRouter();

  useEffect(() => {
    // Clear auth-related data
    localStorage.removeItem("isAuthenticated");
    document.cookie = "sessionid=; Max-Age=0; path=/;"; // Remove session cookie

    // Redirect to login
    router.replace("/login");
  }, [router]);

  return null; 
}
