'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export default function HomeRedirect() {
  const router = useRouter();
  const [hasMounted, setHasMounted] = useState(false);

  useEffect(() => {
    setHasMounted(true); // Ensure this runs only in the browser
  }, []);

  useEffect(() => {
    if (!hasMounted) return;

    const isAuthenticated = localStorage.getItem('isAuthenticated');
    if (isAuthenticated === 'true') {
      router.push('/home'); // Or your real dashboard
    } else {
      router.push('/login');
    }
  }, [hasMounted]);

  return null; // or loading spinner if needed
}
