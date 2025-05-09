'use client';

import { useState } from 'react';
import { ArrowLeft } from 'lucide-react';

export default function ForgotPasswordForm() {
  const [email, setEmail] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Simple email format validation
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      alert('Please enter a valid email address (e.g., example@gmail.com)');
      return;
    }
    alert(`Reset instructions sent to: ${email}`);
  };

  return (
    <div className="space-y-6 max-w-md mx-auto p-6 bg-white rounded-lg shadow-sm">
      <button
        onClick={() => window.history.back()}
        className="text-gray-500 hover:text-[#2853AF] flex items-center"
      >
        <ArrowLeft size={20} />
      </button>

      <h2 className="text-3xl font-bold text-[#2853AF] text-center">Forgot Password?</h2>
      <p className="text-gray-600 text-center">No worries, we'll send you reset instructions.</p>

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
            pattern="[^\s@]+@[^\s@]+\.[^\s@]+"
            className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-[#2853A3] focus:border-transparent text-gray-800"
          />
          <p className="mt-1 text-xs text-gray-500">Please enter a valid email address</p>
        </div>

        <button
          type="submit"
          className="w-full bg-[#2358AF] text-white py-2 rounded-lg hover:bg-[#1d3d7a] transition font-medium"
        >
          Send Code
        </button>
      </form>
    </div>
  );
}