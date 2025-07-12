from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.utils import timezone
from django.contrib.auth import authenticate, login
from datetime import timedelta
from django.db import transaction
import re
import requests
from django.conf import settings
from .models import CustomUser, OTPVerification
from .serializers import RegisterSerializer, VerifyOTPSerializer, ChallengeSerializer, UserChallengeSerializer, UserChallengeHabit, JoinChallengeSerializer, UserChallenge, Challenge, ChallengeHabit
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view
import logging
from rest_framework.authtoken.models import Token


logger = logging.getLogger(__name__)


def format_phone_number(phone):
    """For text.lk: returns 947XXXXXXXX (no +) or None if invalid."""
    phone = normalize_phone_number(phone)
    if phone and phone.startswith('+947'):
        return phone[1:]
    return None


def validate_phone_number(phone_number):
    """Returns True if phone_number is +947XXXXXXXX or 07XXXXXXXX (after normalization)."""
    if not phone_number:
        return False
    if phone_number.startswith('+947') and len(phone_number) == 12 and phone_number[1:].isdigit():
        return True
    return False


def normalize_phone_number(phone):
    phone = phone.strip()
    if phone.startswith('+947') and len(phone) == 12:
        return phone
    elif phone.startswith('07') and len(phone) == 10:
        return '+94' + phone[1:]
    return None


def send_sms_via_textlk(phone_number, message):
    if not all([settings.TEXT_LK_API_KEY, settings.TEXT_LK_SENDER_ID]):
        logger.error("SMS not sent - text.lk credentials not configured")
        return False
    try:
        # Check if we have a normalized phone number (+947 format)
        if phone_number.startswith('+947') and len(phone_number) == 12:
            formatted_phone = phone_number[1:]  # Remove '+' -> 947XXXXXXXX
        else:
            # Normalize other formats
            normalized_phone = normalize_phone_number(phone_number)
            if not normalized_phone:
                logger.error(f"Invalid phone number format: {phone_number}")
                return False
            formatted_phone = normalized_phone[1:]

        logger.info(f"Sending SMS to {formatted_phone}")
        payload = {
            'api_token': settings.TEXT_LK_API_KEY,
            'sender_id': settings.TEXT_LK_SENDER_ID,
            'recipient': formatted_phone,
            'message': message
        }
        headers = {'Content-Type': 'application/json'}
        response = requests.post(
            "https://app.text.lk/api/http/sms/send",
            json=payload,
            headers=headers,
            timeout=10
        )
        logger.info(
            f"Text.lk response: {response.status_code} - {response.text}")
        response.raise_for_status()
        logger.info(f"SMS sent successfully to {formatted_phone}")
        return True
    except Exception as e:
        logger.error(f"Exception sending SMS: {e}")
        return False
# Register View


class RegisterView(generics.GenericAPIView):
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
        data = request.data
        email = data.get('email', '').strip().lower()
        phone_number = data.get('phone_number', '').strip()
        password = data.get('password')
        full_name = data.get('full_name')

        # Validate either email or phone is provided
        if not email and not phone_number:
            return Response({"error": "Email or phone number is required"}, status=status.HTTP_400_BAD_REQUEST)

        if email and phone_number:
            return Response({"error": "Use either email or phone number, not both"}, status=status.HTTP_400_BAD_REQUEST)

        # Normalize and validate phone number if provided
        if phone_number:
            phone_number = normalize_phone_number(phone_number)
            if not phone_number:
                return Response(
                    {"error": "Invalid phone number format. Use +947XXXXXXXX or 07XXXXXXXX"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            if CustomUser.objects.filter(phone_number=phone_number).exists():
                return Response({"error": "Phone number already exists"}, status=status.HTTP_400_BAD_REQUEST)
        else:
            # Email validation
            if CustomUser.objects.filter(email=email).exists():
                return Response({"error": "Email already exists"}, status=status.HTTP_400_BAD_REQUEST)

        otp = get_random_string(length=6, allowed_chars='0123456789')
        logger.info(f"Generated OTP for {phone_number or email}: {otp}")

        # Delete previous OTPs for same identifier
        if phone_number:
            OTPVerification.objects.filter(phone_number=phone_number).delete()
        else:
            OTPVerification.objects.filter(email=email).delete()

        # Create OTP record
        OTPVerification.objects.create(
            email=email if not phone_number else None,
            phone_number=phone_number if phone_number else None,
            otp=otp,
            temp_password=password,
            full_name=full_name,
            created_at=timezone.now()
        )

        # Send OTP via appropriate channel
        if phone_number:
            message = f'Your OTP code is {otp}'
            if not send_sms_via_textlk(phone_number, message):
                logger.error(f"Failed to send SMS to {phone_number}")
                return Response({
                    "message": "Failed to send SMS OTP",
                    "debug_otp": otp
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            return Response({
                "message": "OTP sent to your phone",
                "debug_otp": otp
            }, status=status.HTTP_200_OK)
        else:
            try:
                send_mail(
                    'Your OTP Code',
                    f'Your OTP code is {otp}',
                    settings.DEFAULT_FROM_EMAIL,
                    [email],
                    fail_silently=False,
                )
                return Response({"message": "OTP sent to your email"}, status=status.HTTP_200_OK)
            except Exception as e:
                logger.error(f"Failed to send email: {str(e)}")
                return Response({"error": "Failed to send email OTP"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Verify OTP View
class VerifyOTPView(generics.GenericAPIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()
        phone_number = request.data.get('phone_number', '').strip()
        otp_input = request.data.get('otp', '').strip()

        logger.info(
            f"VerifyOTPView: email={email}, phone={phone_number}, otp={otp_input}")

        if not email and not phone_number:
            return Response({"error": "Email or phone number is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Find OTP record by email or phone
            if email:
                otp_record = OTPVerification.objects.get(
                    email=email, otp=otp_input)
            else:
                phone_number = normalize_phone_number(phone_number)
                otp_record = OTPVerification.objects.get(
                    phone_number=phone_number, otp=otp_input)
        except OTPVerification.DoesNotExist:
            logger.warning(
                f"OTP not found: email={email}, phone={phone_number}")
            return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        if timezone.now() > otp_record.created_at + timedelta(minutes=15):
            otp_record.delete()
            return Response({"error": "OTP expired"}, status=status.HTTP_400_BAD_REQUEST)

        # Create user
        try:
            user = CustomUser.objects.create_user(
                email=email if email else None,
                phone_number=phone_number if phone_number else None,
                password=otp_record.temp_password,
                full_name=otp_record.full_name
            )
        except Exception as e:
            logger.error(f"User creation failed: {str(e)}")
            return Response({"error": "User creation failed"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        otp_record.delete()
        return Response({"message": "User created successfully"}, status=status.HTTP_201_CREATED)

# Login View


class LoginView(APIView):
    def post(self, request, *args, **kwargs):
        identifier = request.data.get(
            'email', '').strip()  # Can be email or phone
        password = request.data.get('password')
        biometric_auth = request.data.get('biometric_auth', False)
        biometric_type = request.data.get(
            'biometric_type', None)  # 'fingerprint' or 'face'

        if not identifier or not password:
            return Response({"error": "Email/phone and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        # Try to find user by email or phone
        try:
            if '@' in identifier:
                user = CustomUser.objects.get(email=identifier.lower())
            else:
                phone = normalize_phone_number(identifier)
                if not validate_phone_number(phone):
                    return Response({"error": "Invalid phone number format"}, status=status.HTTP_400_BAD_REQUEST)
                user = CustomUser.objects.get(phone_number=phone)
        except CustomUser.DoesNotExist:
            return Response({"error": "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)

        # Verify password
        if not user.check_password(password):
            return Response({"error": "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)

        # Log biometric auth attempt with specific type
        if biometric_auth:
            logger.info(
                f"Biometric authentication successful: user={user.email}, type={biometric_type or 'unspecified'}")

        token, created = Token.objects.get_or_create(user=user)
        login(request, user)
        return Response({
            "message": f"{'Biometric' if biometric_auth else 'Login'} successful",
            "token": token.key,
            "user": {
                "email": user.email,
                "phone_number": user.phone_number,
                "full_name": user.full_name
            }
        }, status=status.HTTP_200_OK)

# Social Login View (remains email-only)


@api_view(['POST'])
def social_login(request):
    """
    Handle social login (Google, Facebook, etc.)
    Expected data: email, full_name, provider, provider_id, photo_url (optional)
    """
    try:
        # Get data from request
        email = request.data.get('email')
        full_name = request.data.get('full_name')
        provider = request.data.get('provider')
        provider_id = request.data.get('provider_id')

        # Log the incoming request for debugging
        logger.info(
            f"Social login attempt: email={email}, provider={provider}")

        # Validate required fields
        if not all([email, provider, provider_id]):
            logger.warning(
                f"Missing required fields: email={email}, provider={provider}, provider_id={provider_id}")
            return Response({
                "error": "Missing required fields: email, provider, and provider_id are required"
            }, status=status.HTTP_400_BAD_REQUEST)

        # Validate email format
        if not email or '@' not in email:
            return Response({
                "error": "Invalid email format"
            }, status=status.HTTP_400_BAD_REQUEST)

        # Use transaction to ensure data consistency
        with transaction.atomic():
            try:
                # Try to get existing user
                user = CustomUser.objects.get(email=email)
                created = False

                # Update user info if needed
                if full_name and user.full_name != full_name:
                    user.full_name = full_name
                    user.save()

                logger.info(f"Existing user found: {user.email}")

            except CustomUser.DoesNotExist:
                # Create new user
                user = CustomUser.objects.create_user(
                    email=email,
                    full_name=full_name or f"{provider.title()} User",
                    password=None,  # No password for social login users
                )
                created = True
                logger.info(f"New user created: {user.email}")

            # Generate or get auth token
            token, _ = Token.objects.get_or_create(user=user)

            # Log the user in
            login(request, user)

            # Prepare response
            response_data = {
                "message": "User created successfully" if created else "Login successful",
                "token": token.key,  # Include the token in the response
                "user": {
                    "id": user.id,
                    "email": user.email,
                    "full_name": user.full_name,
                    "is_new_user": created
                }
            }

            return Response(
                response_data,
                status=status.HTTP_201_CREATED if created else status.HTTP_200_OK
            )

    except Exception as e:
        logger.error(f"Social login error: {str(e)}", exc_info=True)
        return Response({
            "error": f"Internal server error occurred during social login: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Forgot Password View


class ForgotPasswordView(APIView):
    def post(self, request, *args, **kwargs):
        identifier = request.data.get('identifier', '').strip()

        if not identifier:
            return Response({"error": "Email or phone number is required"},
                            status=status.HTTP_400_BAD_REQUEST)

        # Determine if it's email or phone
        is_email = '@' in identifier
        is_phone = not is_email

        try:
            if is_phone:
                # Normalize phone number first
                phone = normalize_phone_number(identifier)
                if not phone:
                    return Response(
                        {"error": "Invalid phone number format. Use +947XXXXXXXX or 07XXXXXXXX"},
                        status=status.HTTP_400_BAD_REQUEST
                    )

                # Check if user exists with this phone number
                user = CustomUser.objects.get(phone_number=phone)
                identifier = phone  # Use normalized phone for OTP
            else:
                # Handle email case
                user = CustomUser.objects.get(email=identifier.lower())
                identifier = identifier.lower()

        except CustomUser.DoesNotExist:
            return Response({"error": "Account not found"},
                            status=status.HTTP_400_BAD_REQUEST)

        # Generate OTP
        otp = get_random_string(length=6, allowed_chars='0123456789')
        logger.info(f"Password reset OTP for {identifier}: {otp}")

        # Save or update OTP record
        OTPVerification.objects.update_or_create(
            email=user.email if is_email else None,
            phone_number=user.phone_number if is_phone else None,
            defaults={
                "otp": otp,
                "created_at": timezone.now(),
            }
        )

        # Send OTP via appropriate channel
        if is_phone:
            message = f'Your password reset OTP is {otp}'
            if not send_sms_via_textlk(identifier, message):
                logger.error(f"Failed to send SMS to {identifier}")
                return Response({"error": "Failed to send SMS OTP"},
                                status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            return Response({"message": "OTP sent to your phone"},
                            status=status.HTTP_200_OK)
        else:
            try:
                send_mail(
                    'Password Reset OTP',
                    f'Your OTP for password reset is {otp}',
                    settings.DEFAULT_FROM_EMAIL,
                    [identifier],
                    fail_silently=False,
                )
                return Response({"message": "OTP sent to your email"},
                                status=status.HTTP_200_OK)
            except Exception as e:
                logger.error(f"Failed to send email: {str(e)}")
                return Response({"error": "Failed to send email OTP"},
                                status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Verify Forgot Password OTP View


class VerifyForgotPasswordOTPView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()
        phone_number = request.data.get('phone_number', '').strip()
        otp_input = request.data.get('otp', '').strip()

        logger.info(
            f"VerifyForgotPasswordOTP: email={email}, phone={phone_number}, otp={otp_input}")

        if not email and not phone_number:
            return Response({"error": "Email or phone number is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            if email:
                otp_record = OTPVerification.objects.get(
                    email=email, otp=otp_input)
            else:
                phone_number = normalize_phone_number(phone_number)
                otp_record = OTPVerification.objects.get(
                    phone_number=phone_number, otp=otp_input)
        except OTPVerification.DoesNotExist:
            logger.warning(
                f"Forgot Password OTP not found: email={email}, phone={phone_number}")
            return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        if timezone.now() > otp_record.created_at + timedelta(minutes=15):
            otp_record.delete()
            return Response({"error": "OTP expired"}, status=status.HTTP_400_BAD_REQUEST)

        return Response({"message": "OTP verified successfully"}, status=status.HTTP_200_OK)

# Reset Password View


class ResetPasswordView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()
        phone_number = request.data.get('phone_number', '').strip()
        new_password = request.data.get('new_password', '').strip()
        confirm_password = request.data.get('confirm_password', '').strip()

        if not email and not phone_number:
            return Response({"error": "Email or phone number is required"}, status=status.HTTP_400_BAD_REQUEST)

        if new_password != confirm_password:
            return Response({"error": "Passwords do not match"}, status=status.HTTP_400_BAD_REQUEST)

        # Validate password strength
        if len(new_password) < 8 or not any(char.isupper() for char in new_password) or not any(char.islower() for char in new_password) or not any(char.isdigit() for char in new_password):
            return Response({"error": "Password must be at least 8 characters with uppercase, lowercase and number"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            if email:
                user = CustomUser.objects.get(email=email)
            else:
                phone_number = normalize_phone_number(phone_number)
                user = CustomUser.objects.get(phone_number=phone_number)

            user.set_password(new_password)
            user.save()

            # Clean up OTP record
            if email:
                OTPVerification.objects.filter(email=email).delete()
            else:
                OTPVerification.objects.filter(
                    phone_number=phone_number).delete()

            return Response({"message": "Password reset successfully"}, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({"error": "User does not exist"}, status=status.HTTP_400_BAD_REQUEST)

# Test SMS View


class TestSMSView(APIView):
    def get(self, request):
        phone = request.GET.get('phone')
        if not phone:
            return Response({"error": "?phone= parameter required"})

        phone = normalize_phone_number(phone)
        if not validate_phone_number(phone):
            return Response({"error": "Invalid phone number format"}, status=status.HTTP_400_BAD_REQUEST)

        formatted_phone = format_phone_number(phone)
        if send_sms_via_textlk(formatted_phone, "Test SMS from backend"):
            return Response({"message": "SMS sent successfully"})
        return Response({"error": "SMS failed"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response({"error": "SMS failed"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Resend OTP View


class ResendOTPView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip().lower()
        phone_number = request.data.get('phone_number', '').strip()
        is_forgot_password = request.data.get('is_forgot_password', False)

        if not email and not phone_number:
            return Response({"error": "Email or phone number is required"}, status=status.HTTP_400_BAD_REQUEST)

        # Normalize phone number if provided
        if phone_number:
            phone_number = normalize_phone_number(phone_number)
            if not phone_number:
                return Response(
                    {"error": "Invalid phone number format. Use +947XXXXXXXX or 07XXXXXXXX"},
                    status=status.HTTP_400_BAD_REQUEST
                )

        # Generate new OTP
        otp = get_random_string(length=6, allowed_chars='0123456789')
        logger.info(f"Resent OTP for {phone_number or email}: {otp}")

        # Update or create OTP record
        if phone_number:
            OTPVerification.objects.filter(phone_number=phone_number).delete()
        else:
            OTPVerification.objects.filter(email=email).delete()

        try:
            # Get existing user details for password reset flow
            if is_forgot_password:
                try:
                    if email:
                        user = CustomUser.objects.get(email=email)
                    else:
                        user = CustomUser.objects.get(
                            phone_number=phone_number)

                    # Create OTP record without storing temp data
                    OTPVerification.objects.create(
                        email=email if email else None,
                        phone_number=phone_number if phone_number else None,
                        otp=otp,
                        created_at=timezone.now()
                    )
                except CustomUser.DoesNotExist:
                    return Response({"error": "Account not found"}, status=status.HTTP_404_NOT_FOUND)
            else:
                # For registration flow, get details from previous OTP record
                try:
                    if email:
                        prev_otp = OTPVerification.objects.filter(
                            email=email).first()
                    else:
                        prev_otp = OTPVerification.objects.filter(
                            phone_number=phone_number).first()

                    if not prev_otp:
                        return Response({"error": "No pending registration found"}, status=status.HTTP_404_NOT_FOUND)

                    # Create new OTP record with previous temp data
                    OTPVerification.objects.create(
                        email=email if email else None,
                        phone_number=phone_number if phone_number else None,
                        otp=otp,
                        temp_password=prev_otp.temp_password,
                        full_name=prev_otp.full_name,
                        created_at=timezone.now()
                    )
                except Exception as e:
                    logger.error(f"Error finding previous OTP: {str(e)}")
                    return Response({"error": "Failed to resend OTP"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            # Send OTP via appropriate channel
            if phone_number:
                message = f'Your OTP code is {otp}'
                if not send_sms_via_textlk(phone_number, message):
                    logger.error(f"Failed to send SMS to {phone_number}")
                    return Response({"error": "Failed to send SMS OTP"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                return Response({"message": "OTP resent to your phone"}, status=status.HTTP_200_OK)
            else:
                send_mail(
                    'Your OTP Code',
                    f'Your OTP code is {otp}',
                    settings.DEFAULT_FROM_EMAIL,
                    [email],
                    fail_silently=False,
                )
                return Response({"message": "OTP resent to your email"}, status=status.HTTP_200_OK)
        except Exception as e:
            logger.error(f"Error resending OTP: {str(e)}")
            return Response({"error": f"Failed to resend OTP: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ChallengeListView(generics.ListAPIView):
    serializer_class = ChallengeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Exclude challenges the user has already joined
        user_challenges = UserChallenge.objects.filter(
            user=self.request.user
        ).values_list('challenge_id', flat=True)

        return Challenge.objects.filter(is_active=True).exclude(
            id__in=user_challenges
        )


class UserChallengeListView(generics.ListAPIView):
    serializer_class = UserChallengeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return UserChallenge.objects.filter(
            user=self.request.user,
            is_active=True
        ).prefetch_related('habits__habit')


class JoinChallengeView(generics.GenericAPIView):
    serializer_class = JoinChallengeSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        challenge_id = serializer.validated_data['challenge_id']
        # New: Get selected habit IDs from request
        habit_ids = request.data.get('habit_ids', [])

        try:
            challenge = Challenge.objects.get(
                id=challenge_id,
                is_active=True
            )
        except Challenge.DoesNotExist:
            return Response(
                {"error": "Challenge not found or inactive"},
                status=status.HTTP_404_NOT_FOUND
            )

        # Check if user already joined this challenge
        if UserChallenge.objects.filter(
            user=request.user,
            challenge=challenge
        ).exists():
            return Response(
                {"error": "You have already joined this challenge"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create user challenge
        user_challenge = UserChallenge.objects.create(
            user=request.user,
            challenge=challenge
        )

        # Create user challenge habits only for selected habits
        if habit_ids:
            for habit_id in habit_ids:
                try:
                    habit = ChallengeHabit.objects.get(
                        id=habit_id,
                        challenge=challenge
                    )
                    UserChallengeHabit.objects.create(
                        user_challenge=user_challenge,
                        habit=habit
                    )
                except ChallengeHabit.DoesNotExist:
                    continue
        else:
            # If no habits are selected, add all habits (backward compatibility)
            for habit in challenge.habits.all():
                UserChallengeHabit.objects.create(
                    user_challenge=user_challenge,
                    habit=habit
                )

        return Response(
            {"message": "Successfully joined the challenge"},
            status=status.HTTP_201_CREATED
        )


class UpdateChallengeHabitView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, habit_id, *args, **kwargs):
        try:
            user_habit = UserChallengeHabit.objects.get(
                id=habit_id,
                user_challenge__user=request.user
            )
        except UserChallengeHabit.DoesNotExist:
            return Response(
                {"error": "Habit not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        is_completed = request.data.get('is_completed', False)
        user_habit.is_completed = is_completed
        if is_completed:
            user_habit.completed_date = timezone.now().date()
        else:
            user_habit.completed_date = None
        user_habit.save()

        return Response(
            {"message": "Habit status updated"},
            status=status.HTTP_200_OK
        )

        # Add to the existing views.py file


class JoinChallengeView(generics.GenericAPIView):
    serializer_class = JoinChallengeSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        challenge_id = serializer.validated_data['challenge_id']
        # New: Get selected habit IDs from request
        habit_ids = request.data.get('habit_ids', [])

        try:
            challenge = Challenge.objects.get(
                id=challenge_id,
                is_active=True
            )
        except Challenge.DoesNotExist:
            return Response(
                {"error": "Challenge not found or inactive"},
                status=status.HTTP_404_NOT_FOUND
            )

        # Check if user already joined this challenge
        if UserChallenge.objects.filter(
            user=request.user,
            challenge=challenge
        ).exists():
            return Response(
                {"error": "You have already joined this challenge"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create user challenge
        user_challenge = UserChallenge.objects.create(
            user=request.user,
            challenge=challenge
        )

        # Create user challenge habits only for selected habits
        if habit_ids:
            for habit_id in habit_ids:
                try:
                    habit = ChallengeHabit.objects.get(
                        id=habit_id,
                        challenge=challenge
                    )
                    UserChallengeHabit.objects.create(
                        user_challenge=user_challenge,
                        habit=habit
                    )
                except ChallengeHabit.DoesNotExist:
                    continue
        else:
            # If no habits are selected, add all habits (backward compatibility)
            for habit in challenge.habits.all():
                UserChallengeHabit.objects.create(
                    user_challenge=user_challenge,
                    habit=habit
                )

        return Response(
            {"message": "Successfully joined the challenge"},
            status=status.HTTP_201_CREATED
        )
