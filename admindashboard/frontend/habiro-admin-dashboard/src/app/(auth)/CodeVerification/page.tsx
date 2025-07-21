import CodeVerificationForm from './CodeVerificationForm';
import Image from 'next/image';

export default function CodeVerificationPage() {
  return (
    <div className="min-h-screen bg-gray-100">
      {/* Logo at the top-left */}
      <div className="pt-6 pl-6">
        <Image
          src="/images/login/habitro_logo.png"
          alt="HABITRO"
          width={150}
          height={50}
          className="object-contain"
        />
      </div>

      {/* Main content centered */}
            <div className="flex items-center justify-center min-h-[calc(100vh-120px)] px-4">
              <div className="bg-white p-8 rounded-2xl shadow-md w-full max-w-4xl flex flex-col md:flex-row items-center gap-8">
                <div className="w-full md:w-1/2">
                  <CodeVerificationForm />
                </div>
                <div className="w-full md:w-1/2 hidden md:flex justify-center">
                  <Image
                    src="/images/login/dashboard3.png"
                    alt="Password Reset Illustration"
                    width={500}
                    height={500}
                    className="object-contain max-w-sm"
                  />
                </div>
              </div>
            </div>
          </div>
  );
}