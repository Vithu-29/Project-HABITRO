from rest_framework import serializers
from django.core.validators import MinLengthValidator
from .models import CustomUser
import re
from .models import Challenge, ChallengeHabit, UserChallenge, UserChallengeHabit


def normalize_phone_number(phone_number):
    """
    Normalize Sri Lankan phone numbers to the format +947XXXXXXXX.
    Accepts numbers starting with +947 or 07.
    """
    if phone_number.startswith('+947') and len(phone_number) == 12:
        return phone_number
    elif phone_number.startswith('07') and len(phone_number) == 10:
        return '+94' + phone_number[1:]
    return None


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'},
        min_length=8,
        error_messages={
            'min_length': 'Password must be at least 8 characters long.'
        }
    )
    confirm_password = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'}

    )

    class Meta:
        model = CustomUser
        fields = ['email', 'full_name', 'password', 'confirm_password']
        extra_kwargs = {
            'email': {'required': True}
        }

        phone_number = serializers.CharField(required=False, allow_blank=True)

    def validate(self, data):
        email = data.get('email')
        phone_number = data.get('phone_number')

        # Require either email or phone, not both
        if not email and not phone_number:
            raise serializers.ValidationError({
                'identifier': 'Email or phone number is required.'
            })
        if email and phone_number:
            raise serializers.ValidationError({
                'identifier': 'Use either email or phone number, not both.'
            })

        # Validate phone format if provided
        if phone_number:
            if not re.match(r'^(\+947\d{8}|07\d{8})$', phone_number):
                raise serializers.ValidationError({
                    'phone_number': 'Invalid phone number format. Use +947XXXXXXXX or 07XXXXXXXX'
                })

                # Normalize phone number before checking existence
            normalized_phone = normalize_phone_number(phone_number)
            if not normalized_phone:
                raise serializers.ValidationError({
                    'phone_number': 'Invalid phone number format'
                })

            if CustomUser.objects.filter(phone_number=normalized_phone).exists():
                raise serializers.ValidationError({
                    'phone_number': 'Phone number already exists'
                })
            data['phone_number'] = normalized_phone

        # Ensure passwords match
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError({
                'confirm_password': 'Passwords do not match.'
            })

        return data

    def create(self, validated_data):
        # Remove confirm_password before saving
        validated_data.pop('confirm_password')

        # Create user based on provided credentials
        user = CustomUser.objects.create_user(
            email=validated_data['email'],
            full_name=validated_data['full_name'],
            password=validated_data['password']
        )
        return user


class VerifyOTPSerializer(serializers.Serializer):
    otp = serializers.CharField(
        max_length=6,
        min_length=6,
        required=True,
        validators=[MinLengthValidator(6)],
        error_messages={
            'required': 'OTP is required.',
            'min_length': 'OTP must be exactly 6 characters.',
            'max_length': 'OTP must be exactly 6 characters.'
        }
    )
    email = serializers.EmailField(
        required=False,
        allow_blank=True,
        error_messages={
            'invalid': 'Enter a valid email address.'
        }
    )
    phone_number = serializers.CharField(
        required=False,
        allow_blank=True,
        error_messages={
            'invalid': 'Enter a valid phone number'
        }
    )

    def validate(self, data):
        email = data.get('email')
        phone_number = data.get('phone_number')

        if not email and not phone_number:
            raise serializers.ValidationError(
                'Email or phone number is required')
        return data

    def validate_otp(self, value):
        """Additional validation for OTP format"""
        if not value.isdigit():
            raise serializers.ValidationError("OTP must contain only digits.")
        return value


class ChallengeHabitSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChallengeHabit
        fields = ['id', 'title', 'description', 'frequency']


class ChallengeSerializer(serializers.ModelSerializer):
    habits = ChallengeHabitSerializer(many=True, read_only=True)

    class Meta:
        model = Challenge
        fields = ['id', 'title', 'description',
                  'category', 'duration_days', 'habits']


class UserChallengeHabitSerializer(serializers.ModelSerializer):
    habit = ChallengeHabitSerializer(read_only=True)

    class Meta:
        model = UserChallengeHabit
        fields = ['id', 'habit', 'is_completed', 'completed_date']


class UserChallengeSerializer(serializers.ModelSerializer):
    challenge = ChallengeSerializer(read_only=True)
    habits = UserChallengeHabitSerializer(many=True, read_only=True)

    class Meta:
        model = UserChallenge
        fields = ['id', 'challenge', 'start_date', 'is_active', 'habits']


class JoinChallengeSerializer(serializers.Serializer):
    challenge_id = serializers.IntegerField(required=True)
