import CodeVerificationForm from './CodeVerificationForm';
import Image from 'next/image';

export default function CodeVerificationPage() {
  return (
    <main className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="bg-white p-8 rounded-2xl shadow-md w-full max-w-4xl flex flex-col md:flex-row items-center gap-6">
        <div className="w-full md:w-1/2">
          <CodeVerificationForm />
        </div>
        <div className="w-full md:w-1/2 hidden md:flex justify-center">
          <Image
            src="/dashboard3.png"
            alt="Code Verification Illustration"
            width={500}
            height={500}
            className="object-contain max-w-sm"
          />
        </div>
      </div>
    </main>
  );
}