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
from rest_framework.authtoken.models import Token

#  Register View


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

        #  registration data
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

# Verify OTP View


class VerifyOTPView(generics.GenericAPIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()
        otp_input = request.data.get('otp', '').strip()

        try:
            otp_record = OTPVerification.objects.get(
                email=email, otp=otp_input)
        except OTPVerification.DoesNotExist:
            return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        if timezone.now() > otp_record.created_at + timedelta(minutes=15):
            otp_record.delete()
            return Response({"error": "OTP expired"}, status=status.HTTP_400_BAD_REQUEST)

        # Create user
        CustomUser.objects.create_user(
            email=email,
            password=otp_record.temp_password,
            full_name=otp_record.full_name
        )

        otp_record.delete()

        return Response({"message": "User created successfully"}, status=status.HTTP_201_CREATED)

#  Login View


class LoginView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        password = request.data.get('password')

        user = authenticate(request, username=email, password=password)

        if user is not None:
            # Generate or get existing token
            token, _ = Token.objects.get_or_create(user=user)
            return Response({
                "token": token.key,  # Include token in response
                "message": "Login successful",
                "user_id": user.id,  # Optional: Include user details
                "email": user.email
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                "error": "Invalid email or password"
            }, status=status.HTTP_400_BAD_REQUEST)

# Forgot Password View
class ForgotPasswordView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()

        # Check if the email exists in the database
        try:
            user = CustomUser.objects.get(email=email)
        except CustomUser.DoesNotExist:
            return Response({"error": "Email does not exist"}, status=status.HTTP_400_BAD_REQUEST)

        # Generate a 6-digit OTP
        otp = get_random_string(length=6, allowed_chars='0123456789')

        # Save or update the OTP in the database
        OTPVerification.objects.update_or_create(
            email=email,
            defaults={
                "otp": otp,
                "created_at": timezone.now(),
            }
        )

        # Send the OTP to the user's email
        try:
            send_mail(
                'Password Reset OTP',
                f'Your OTP for password reset is {otp}',
                'noreply@yourapp.com',  # sender email
                [email],
                fail_silently=False,
            )
        except Exception as e:
            return Response({"error": f"Failed to send email: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({"message": "OTP sent to your email"}, status=status.HTTP_200_OK)

# Verify Forgot Password OTP View


class VerifyForgotPasswordOTPView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()
        otp_input = request.data.get('otp', '').strip()

        # Check if the OTP is valid
        try:
            otp_record = OTPVerification.objects.get(
                email=email, otp=otp_input)
        except OTPVerification.DoesNotExist:
            return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        # Check if OTP has expired
        if timezone.now() > otp_record.created_at + timedelta(minutes=15):
            otp_record.delete()
            return Response({"error": "OTP expired"}, status=status.HTTP_400_BAD_REQUEST)

        return Response({"message": "OTP verified successfully"}, status=status.HTTP_200_OK)

#  Reset Password View


class ResetPasswordView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()
        new_password = request.data.get('new_password', '').strip()
        confirm_password = request.data.get('confirm_password', '').strip()

        # Check if passwords match
        if new_password != confirm_password:
            return Response({"error": "Passwords do not match"}, status=status.HTTP_400_BAD_REQUEST)

        # Validate password strength
        if len(new_password) < 8 or not any(char.isupper() for char in new_password) or not any(char.islower() for char in new_password) or not any(char.isdigit() for char in new_password):
            return Response({"error": "Password does not meet the required conditions"}, status=status.HTTP_400_BAD_REQUEST)

        # Update password
        try:
            user = CustomUser.objects.get(email=email)
            user.set_password(new_password)
            user.save()

            # Optionally clean up OTP record after reset
            OTPVerification.objects.filter(email=email).delete()

            return Response({"message": "Password reset successfully"}, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({"error": "User does not exist"}, status=status.HTTP_400_BAD_REQUEST)
