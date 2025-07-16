import ResetPasswordForm from './ResetPasswordForm';
import Image from 'next/image';

export default function ResetPasswordPage() {
  return (
    <main className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="bg-white p-8 rounded-2xl shadow-md w-full max-w-4xl flex flex-col md:flex-row items-center gap-8">
        <div className="w-full md:w-1/2">
          <ResetPasswordForm />
        </div>
        <div className="w-full md:w-1/2 hidden md:flex justify-center">
          <Image
            src="/dashboard4.png"
            alt="Password Reset Illustration"
            width={500}
            height={500}
            className="object-contain max-w-sm"
          />
        </div>
      </div>
    </main>
  );
}