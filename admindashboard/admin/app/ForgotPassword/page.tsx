import ForgotPasswordForm from './ForgotPasswordForm';

export default function ForgotPasswordPage() {
  return (
    <main className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="bg-white p-8 rounded-2xl shadow-md w-full max-w-4xl flex flex-col md:flex-row items-center gap-6">
        <div className="w-full md:w-1/2">
          <ForgotPasswordForm />
        </div>
        <div className="w-full md:w-1/2 hidden md:flex justify-center">
          <img src="/dashboard2.png" alt="Forgot Password Illustration" className="max-w-sm" />
        </div>
      </div>
    </main>
  );
}