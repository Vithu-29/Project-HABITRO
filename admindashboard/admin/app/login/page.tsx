import RegisterForm from './LoginForm'; // Renamed from LoginForm to RegisterForm

export default function RegisterPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
      <div className="bg-white p-10 rounded-2xl shadow-xl flex flex-col md:flex-row gap-10 w-full max-w-4xl">
        <RegisterForm />
        <div className="hidden md:flex items-center justify-center flex-1">
          <img src="/dashboard1.png" alt="Welcome" className="max-w-xs" />
        </div>
      </div>
    </div>
  );
}