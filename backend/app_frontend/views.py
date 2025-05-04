from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.utils import timezone
from django.contrib.auth import authenticate
from datetime import timedelta
from .models import CustomUser, OTPVerification
from .serializers import RegisterSerializer, VerifyOTPSerializer

# Registration Step 1: Send OTP and Temporarily Store Data


class RegisterView(generics.GenericAPIView):
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
        data = request.data
        email = data.get('email')
        password = data.get('password')
        full_name = data.get('full_name')

        if CustomUser.objects.filter(email=email).exists():
            return Response({"error": "Email already exists"}, status=status.HTTP_400_BAD_REQUEST)

        otp = get_random_string(length=6, allowed_chars='0123456789')

        # Delete previous OTPs for same email
        OTPVerification.objects.filter(email=email).delete()

        # Save temp registration data with OTP
        OTPVerification.objects.create(
            email=email,
            otp=otp,
            temp_password=password,
            full_name=full_name,
            created_at=timezone.now()
        )

        send_mail(
            'Your OTP Code',
            f'Your OTP code is {otp}',
            'noreply@yourapp.com',
            [email],
            fail_silently=False,
        )

        return Response({"message": "OTP sent to your email"}, status=status.HTTP_200_OK)

# Registration Step 2: Verify OTP and Create Account


class VerifyOTPView(generics.GenericAPIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()
        otp_input = request.data.get('otp', '').strip()

        print("Incoming verify request:")
        print("Email:", email)
        print("OTP:", otp_input)

        # Debug: Print all OTP records (optional)
        all_records = OTPVerification.objects.all().values()
        print("Current OTP records in DB:", list(all_records))

        try:
            otp_record = OTPVerification.objects.get(
                email=email, otp=otp_input)
        except OTPVerification.DoesNotExist:
            return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        # Check if OTP has expired
        if timezone.now() > otp_record.created_at + timedelta(minutes=5):
            print("OTP Expiration Check:")
            print("Created At:", otp_record.created_at)
            print("Current Time:", timezone.now())
            print("Expired: True")
            otp_record.delete()
            return Response({"error": "OTP expired"}, status=status.HTTP_400_BAD_REQUEST)

        # Debug: OTP is valid
        print("OTP Expiration Check:")
        print("Created At:", otp_record.created_at)
        print("Current Time:", timezone.now())
        print("Expired: False")

        # Create user
        CustomUser.objects.create_user(
            email=email,
            password=otp_record.temp_password,
            full_name=otp_record.full_name
        )

        # Delete OTP record after success
        otp_record.delete()

        return Response({"message": "User created successfully"}, status=status.HTTP_201_CREATED)

# Login View


class LoginView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        password = request.data.get('password')


        # Authenticate the user
        user = authenticate(request, username=email, password=password)

        if user is not None:
            return Response({"message": "Login successful"}, status=status.HTTP_200_OK)
        else:
            return Response({"error": "Invalid email or password"}, status=status.HTTP_400_BAD_REQUEST)
