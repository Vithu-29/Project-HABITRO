from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.core.mail import send_mail
from django.conf import settings
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
        serializer = ForgotPasswordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        email = serializer.validated_data['email']
        logger.info(f"Password reset requested for: {email}")
        
        try:
            otp = HabitroAdminManager.generate_otp(request, email)
            if not otp:
                return Response(
                    {"error": "No account found with this email"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            send_mail(
                'Password Reset OTP',
                f'Your OTP is: {otp}\nValid for 10 minutes.',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )
            
            return Response({
                "message": "OTP sent to your email"
            })
            
        except Exception as e:
            logger.error(f"Forgot password error: {str(e)}", exc_info=True)
            return Response(
                {"error": "Failed to process request"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class VerifyOTPView(APIView):
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        otp = serializer.validated_data['otp']
        logger.info(f"Verifying OTP: {otp}")
        
        if HabitroAdminManager.verify_otp(request, otp):
            return Response({
                "message": "OTP verified successfully",
                "verified": True
            })
        else:
            return Response(
                {"error": "Invalid or expired OTP", "verified": False},
                status=status.HTTP_400_BAD_REQUEST
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