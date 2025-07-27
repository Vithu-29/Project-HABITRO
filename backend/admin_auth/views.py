from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.middleware.csrf import get_token
from django.core.mail import send_mail
from django.conf import settings
from django.contrib.auth import authenticate
from django.views.decorators.csrf import csrf_exempt
import logging

from .models import HabitroAdminManager
from .serializers import (
    ForgotPasswordSerializer,
    VerifyOTPSerializer,
    ResetPasswordSerializer
)

logger = logging.getLogger(__name__)


class AdminLoginView(APIView):
    def post(self, request):
        email = request.data.get('email', '').strip()
        password = request.data.get('password', '').strip()

        logger.debug(f"Login attempt for email: {email}")

        if not all([email, password]):
            logger.warning("Login attempt with missing credentials")
            return Response({"error": "Both fields required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            admin_id = HabitroAdminManager.authenticate(email, password)
            if admin_id:
                request.session['admin_id'] = admin_id
                logger.info(f"Successful login for admin ID: {admin_id}")

                response = Response({
                    "status": "success",
                    "email": email,
                    "redirect": "/dashboard"
                }, status=status.HTTP_200_OK)

                response.set_cookie('sessionid', request.session.session_key)
                return response

            logger.warning(f"Failed login attempt for email: {email}")
            return Response(
                {"error": "Invalid credentials"},
                status=status.HTTP_401_UNAUTHORIZED
            )

        except Exception as e:
            logger.error(f"Login error for {email}: {str(e)}")
            return Response(
                {"error": "Authentication failed"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ForgotPasswordView(APIView):
    def post(self, request):
        if not request.session.session_key:
            request.session.create()

        serializer = ForgotPasswordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        logger.info(f"Password reset requested for: {email}")

        try:
            request.session['reset_email'] = email
            request.session.modified = True

            otp = HabitroAdminManager.generate_otp(request, email)
            if not otp:
                return Response(
                    {"error": "No account found with this email"},
                    status=status.HTTP_404_NOT_FOUND
                )

            request.session.save()

            send_mail(
                'Password Reset OTP',
                f'Your OTP is: {otp}\nValid for 10 minutes.',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )

            response = Response({"message": "OTP sent to your email"})

            response.set_cookie(
                settings.SESSION_COOKIE_NAME,
                request.session.session_key,
                max_age=settings.SESSION_COOKIE_AGE,
                domain=settings.SESSION_COOKIE_DOMAIN,
                path=settings.SESSION_COOKIE_PATH,
                secure=settings.SESSION_COOKIE_SECURE,
                httponly=settings.SESSION_COOKIE_HTTPONLY,
                samesite=settings.SESSION_COOKIE_SAMESITE
            )

            return response

        except Exception as e:
            logger.error(f"Forgot password error: {str(e)}", exc_info=True)
            return Response(
                {"error": "Failed to process request"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class VerifyOTPView(APIView):
    def post(self, request):
        logger.info(f"Session data: {dict(request.session)}")

        serializer = VerifyOTPSerializer(data=request.data)
        if not serializer.is_valid():
            logger.error(f"Serializer errors: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        otp = serializer.validated_data['otp']
        logger.info(f"Verifying OTP: {otp} for session {request.session.session_key}")

        try:
            if not request.session.get('reset_otp'):
                logger.error("No OTP found in session")
                return Response(
                    {"error": "OTP session expired or invalid"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            if HabitroAdminManager.verify_otp(request, otp):
                request.session['otp_verified'] = True
                request.session.save()
                return Response({
                    "message": "OTP verified successfully",
                    "verified": True
                })

            return Response(
                {"error": "Invalid or expired OTP", "verified": False},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            logger.error(f"OTP verification error: {str(e)}")
            return Response(
                {"error": "OTP verification failed"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ResetPasswordView(APIView):
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        new_password = serializer.validated_data['new_password']

        if HabitroAdminManager.reset_password(request, new_password):
            return Response({
                "message": "Password reset successfully"
            })
        else:
            return Response(
                {"error": "Failed to reset password"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class GetCSRFToken(APIView):
    def get(self, request):
        return Response({'csrfToken': get_token(request)})


# ✅ Change password view with CSRF exempted for token-auth clients
@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    user = request.user
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')

    if not old_password or not new_password:
        return Response({'error': 'Both old and new passwords are required'}, status=status.HTTP_400_BAD_REQUEST)

    if not user.check_password(old_password):
        return Response({'error': 'Incorrect current password'}, status=status.HTTP_400_BAD_REQUEST)

    if len(new_password) < 8:
        return Response({'error': 'New password must be at least 8 characters long'}, status=status.HTTP_400_BAD_REQUEST)

    user.set_password(new_password)
    user.save()

    return Response({'detail': 'Password changed successfully'}, status=status.HTTP_200_OK)
