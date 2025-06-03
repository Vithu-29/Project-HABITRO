'use client';

import { useState, useRef, KeyboardEvent, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { ArrowLeft } from 'lucide-react';

export default function CodeVerificationForm() {
  const [code, setCode] = useState(['', '', '', '', '', '']);
  const [isResending, setIsResending] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const router = useRouter();
  const searchParams = useSearchParams();
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);
  const email = searchParams.get('email') || '';

  const handleCodeChange = (index: number, value: string) => {
    if (/^\d*$/.test(value) && value.length <= 1) {
      const newCode = [...code];
      newCode[index] = value;
      setCode(newCode);

      if (value && index < 5) {
        inputRefs.current[index + 1]?.focus();
      }
    }
  };

  const handleKeyDown = (index: number, e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !code[index] && index > 0) {
      const newCode = [...code];
      newCode[index - 1] = '';
      setCode(newCode);
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    const fullCode = code.join('');
    
    if (fullCode.length !== 6) {
      setError('Please enter a 6-digit code');
      return;
    }

    setIsLoading(true);
    setError('');
    setSuccess('');

    try {
      const response = await fetch('http://127.0.0.1:8000/admin_auth/verify-otp/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'},
        credentials: 'include',  // This is crucial for sending cookies
        body: JSON.stringify({ 
          otp: fullCode,
          email: email.toLowerCase().trim()
        })
      });
      


      const data = await response.json();
      
      if (!response.ok) {
        throw new Error(data.error || 'Invalid or expired OTP');
      }

      setSuccess('Verification successful! Redirecting...');
      setTimeout(() => router.push('/ResetPassword'), 1000);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Verification failed');
    } finally {
      setIsLoading(false);
    }
  };

  const handleResendCode = async () => {
    setIsResending(true);
    setError('');
    
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
        throw new Error(data.error || 'Failed to resend OTP');
      }

      alert('New OTP sent successfully!');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Resend failed');
    } finally {
      setIsResending(false);
    }
  };

  return (
    <div className="w-full">
      <button
        onClick={() => router.back()}
        className="text-gray-500 hover:text-[#2853AF] flex items-center mb-4"
      >
        <ArrowLeft size={20} />
      </button>

      <h2 className="text-3xl font-semibold text-[#2853AF] text-center mb-2">Enter code</h2>

      <p className="text-gray-600 text-center mb-6">
        We sent a code to <span className="font-medium">{email}</span>
      </p>

      {error && <div className="mb-4 p-3 bg-red-100 text-red-700 rounded-lg">{error}</div>}
      {success && <div className="mb-4 p-3 bg-green-100 text-green-700 rounded-lg">{success}</div>}

      <form onSubmit={handleVerify} className="space-y-6">
        <div className="flex justify-center space-x-3">
          {code.map((digit, index) => (
            <input
              key={index}
              ref={(el) => { inputRefs.current[index] = el; }}
              id={`code-${index}`}
              type="text"
              inputMode="numeric"
              pattern="[0-9]*"
              maxLength={1}
              value={digit}
              onChange={(e) => handleCodeChange(index, e.target.value)}
              onKeyDown={(e) => handleKeyDown(index, e)}
              className="w-12 h-12 text-3xl font-bold text-center border-2 border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#2853AF] focus:border-transparent text-gray-500"
              autoFocus={index === 0}
            />
          ))}
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className={`w-full bg-[#2853AF] text-white py-3 rounded-lg hover:bg-[#1d4299] font-medium transition ${
            isLoading ? 'opacity-80' : ''
          }`}
        >
          {isLoading ? 'Verifying...' : 'Verify'}
        </button>

        <div className="text-center text-gray-600">
          <p>
            Didn't receive code yet?{' '}
            <button
              type="button"
              onClick={handleResendCode}
              disabled={isResending}
              className="text-[#2853AF] hover:text-[#1d4299] font-medium disabled:opacity-50"
            >
              {isResending ? 'Sending...' : 'Resend'}
            </button>
          </p>
        </div>
      </form>
    </div>
  );
}