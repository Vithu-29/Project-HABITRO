'use client';

import { useState, useRef, KeyboardEvent } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft } from 'lucide-react';

export default function CodeVerificationForm() {
  const [code, setCode] = useState(['', '', '', '', '', '']);
  const [isResending, setIsResending] = useState(false);
  const router = useRouter();
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  const handleCodeChange = (index: number, value: string) => {
    if (/^\d*$/.test(value) && value.length <= 1) {
      const newCode = [...code];
      newCode[index] = value;
      setCode(newCode);

      // Auto-focus next input when a digit is entered
      if (value && index < 5) {
        inputRefs.current[index + 1]?.focus();
      }
    }
  };

  const handleKeyDown = (index: number, e: KeyboardEvent<HTMLInputElement>) => {
    // Handle backspace key
    if (e.key === 'Backspace' && !code[index] && index > 0) {
      const newCode = [...code];
      newCode[index - 1] = '';
      setCode(newCode);
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handleVerify = (e: React.FormEvent) => {
    e.preventDefault();
    const fullCode = code.join('');
    if (fullCode.length === 6) {
      alert(`Verifying code: ${fullCode}`);
      // Add your verification logic here
      // router.push('/dashboard');
    } else {
      alert('Please enter a 6-digit code');
    }
  };

  const handleResendCode = async () => {
    setIsResending(true);
    await new Promise(resolve => setTimeout(resolve, 1000));
    alert('New code sent to example@gmail.com');
    setIsResending(false);
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
        We sent a code to <span className="font-medium">example@gmail.com</span>
      </p>

      <form onSubmit={handleVerify} className="space-y-6">
        <div className="flex justify-center space-x-3">
          {code.map((digit, index) => (
            <input
            key={index}ref={(el) => {inputRefs.current[index] = el;}}
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
          className="w-full bg-[#2853AF] text-white py-3 rounded-lg hover:bg-[#1d4299] font-medium transition"
        >
          Verify
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