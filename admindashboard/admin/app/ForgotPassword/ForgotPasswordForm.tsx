'use client';
import { useState } from 'react';
import { ArrowLeft } from 'lucide-react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';

export default function ForgotPasswordForm() {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('Please enter a valid email address');
      return;
    }

    setIsLoading(true);

    try {
      const response = await fetch('http://127.0.0.1:8000/admin_auth/forgot-password/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify({ email: email.toLowerCase().trim() })
      });

      const data = await response.json();
      
      if (!response.ok) {
        throw new Error(data.error || 'Failed to send OTP');
      }

      setSuccess('OTP sent successfully!');
      setTimeout(() => router.push(`/CodeVerification?email=${encodeURIComponent(email)}`), 1000);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to send OTP');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="space-y-6 max-w-md mx-auto p-6 bg-white rounded-lg shadow-sm">
      <Link href="/login" className="text-gray-500 hover:text-[#2853AF] flex items-center">
        <ArrowLeft size={20} />
      </Link>

      <h2 className="text-3xl font-bold text-[#2853AF] text-center">Forgot Password?</h2>
      <p className="text-gray-600 text-center">No worries, we'll send you reset instructions.</p>

      {error && <div className="mb-4 p-3 bg-red-100 text-red-700 rounded-lg">{error}</div>}
      {success && <div className="mb-4 p-3 bg-green-100 text-green-700 rounded-lg">{success}</div>}

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="email" className="block font-medium text-gray-700 mb-1 text-sm">
            Email Address
          </label>
          <input
            type="email"
            id="email"
            placeholder="example@gmail.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-[#2853A3] focus:border-transparent text-gray-800"
          />
          <p className="mt-1 text-xs text-gray-500">Please enter a valid email address</p>
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className="w-full bg-[#2358AF] text-white py-2 rounded-lg hover:bg-[#1d3d7a] transition font-medium disabled:opacity-50"
        >
          {isLoading ? 'Sending...' : 'Send Code'}
        </button>
      </form>
    </div>
  );
}