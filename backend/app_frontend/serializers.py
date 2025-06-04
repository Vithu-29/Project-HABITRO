from rest_framework import serializers
from django.core.validators import MinLengthValidator
from .models import CustomUser


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

    def validate(self, data):
        # Ensure email is provided
        if not data.get('email'):
            raise serializers.ValidationError({
                'email': 'Email is required.'
            })

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
        required=True,
        error_messages={
            'required': 'Email is required for OTP verification.',
            'invalid': 'Enter a valid email address.'
        }
    )

    def validate_otp(self, value):
        """Additional validation for OTP format"""
        if not value.isdigit():
            raise serializers.ValidationError("OTP must contain only digits.")
        return value
