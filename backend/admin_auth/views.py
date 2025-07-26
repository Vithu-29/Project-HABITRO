from rest_framework.views import APIView
from django.middleware.csrf import get_token
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.core.mail import send_mail
from django.conf import settings
import logging
import secrets 
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

                # Generate a unique token for this login session (not stored in DB)
                session_token = secrets.token_hex(32)
                print(
                    f"[ADMIN LOGIN TOKEN] Admin: {email}, Token: {session_token}")

                response = Response({
                    "status": "success",
                    "email": email,
                    "redirect": "/dashboard",
                    "token": session_token  # <-- Return token to frontend
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
        # Ensure session exists before proceeding
        if not request.session.session_key:
            request.session.create()

        serializer = ForgotPasswordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        logger.info(f"Password reset requested for: {email}")

        try:
            # Store email in session immediately
            request.session['reset_email'] = email
            request.session.modified = True

            otp = HabitroAdminManager.generate_otp(request, email)
            if not otp:
                return Response(
                    {"error": "No account found with this email"},
                    status=status.HTTP_404_NOT_FOUND
                )

            # Force session save and set cookie headers
            request.session.save()

            send_mail(
                'Password Reset OTP',
                f'Your OTP is: {otp}\nValid for 10 minutes.',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )

            response = Response({"message": "OTP sent to your email"})

            # Explicitly set session cookie in response
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

        # Debug logging
        logger.info(f"Session data: {dict(request.session)}")

        serializer = VerifyOTPSerializer(data=request.data)
        if not serializer.is_valid():
            logger.error(f"Serializer errors: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        otp = serializer.validated_data['otp']
        logger.info(
            f"Verifying OTP: {otp} for session {request.session.session_key}")

        try:
            if not request.session.get('reset_otp'):
                logger.error("No OTP found in session")
                return Response(
                    {"error": "OTP session expired or invalid"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            if HabitroAdminManager.verify_otp(request, otp):
                # Ensure session is saved
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