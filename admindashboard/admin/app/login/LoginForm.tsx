'use client';

import { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';

export default function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const validatePassword = (password: string) => {
    const hasUpper = /[A-Z]/.test(password);
    const hasLower = /[a-z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    const hasSymbol = /[!@#$%^&*(),.?":{}|<>]/.test(password);
    return hasUpper && hasLower && hasNumber && hasSymbol;
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();

    if (!email || !password) {
      alert('Please enter both email and password');
      return;
    }

    if (!validatePassword(password)) {
      alert(
        'Password must include uppercase, lowercase, number, and special character'
      );
      return;
    }

    alert('Login submitted!');
  };

  return (
    <form
      onSubmit={handleLogin}
      className="flex-1 max-w-md mx-auto p-6 bg-white rounded-lg shadow-md"
    >
      <h1 className="text-3xl font-bold mb-6 text-blue-800 text-center">Welcome Back!</h1>

      {/* Email */}
      <label className="block mb-2 font-medium text-gray-800">Email</label>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="example@domain.com"
        className="w-full px-4 py-2 border border-gray-300 rounded-lg mb-4 bg-gray-50 text-black placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
        required
      />

      {/* Password */}
      <label className="block mb-2 font-medium text-gray-800">Password</label>
      <div className="relative mb-4">
        <input
          type={showPassword ? 'text' : 'password'}
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Enter your password"
          className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-black placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
          required
        />
        <button
          type="button"
          onClick={() => setShowPassword(!showPassword)}
          className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-600"
          aria-label="Toggle password visibility"
        >
          {showPassword ? <Eye size={20} /> : <EyeOff size={20} />}
        </button>
      </div>

      {/* Remember Me + Forgot Password */}
      <div className="flex justify-between items-center text-sm mb-4 text-gray-600">
        <label className="flex items-center">
          <input type="checkbox" className="mr-2" /> Remember Me
        </label>
        <a href="#" className="text-blue-600 hover:underline font-medium">
          Forgot Password?
        </a>
      </div>

      {/* Submit */}
      <button
        type="submit"
        className="w-full bg-blue-700 text-white py-2 rounded-lg hover:bg-blue-800 font-semibold transition"
      >
        Sign In
      </button>
    </form>
  );
}
