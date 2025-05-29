from rest_framework import serializers
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
import re
import logging

logger = logging.getLogger(__name__)

class AdminLoginSerializer(serializers.Serializer):
    email = serializers.CharField(required=True)
    password = serializers.CharField(
        write_only=True,
        required=True,
        trim_whitespace=False,
        style={'input_type': 'password'}
    )

    def validate_email(self, value):
        """Validate and normalize email format"""
        value = value.lower().strip()
        try:
            validate_email(value)
            return value
        except ValidationError as e:
            logger.warning(f"Invalid email format: {value}")
            raise serializers.ValidationError("Enter a valid email address")

    def validate(self, data):
        """Main validation logic"""
        email = data.get('email')
        password = data.get('password')
        
        if not email or not password:
            logger.warning("Missing credentials in request")
            raise serializers.ValidationError({
                'non_field_errors': ['Email and password are required']
            })

        try:
            with connections['habitro'].cursor() as cursor:
                cursor.execute(
                    """
                    SELECT id, email, password, g_active, 
                    iq_staff, iq_superuser, last_login
                    FROM admin_details 
                    WHERE email = %s
                    """,
                    [email]
                )
                result = cursor.fetchone()
                
                if not result:
                    logger.warning(f"Admin not found: {email}")
                    raise serializers.ValidationError({
                        'non_field_errors': ['Invalid email or password']
                    })
                
                admin_data = {
                    'id': result[0],
                    'email': result[1],
                    'password': result[2],
                    'is_active': bool(result[3]),
                    'is_staff': bool(result[4]),
                    'is_superuser': bool(result[5]),
                    'last_login': result[6]
                }
                
                if not admin_data['is_active']:
                    logger.warning(f"Inactive admin account: {email}")
                    raise serializers.ValidationError({
                        'non_field_errors': ['Account is inactive']
                    })
                
                if not check_password(password, admin_data['password']):
                    logger.warning(f"Invalid password for: {email}")
                    raise serializers.ValidationError({
                        'non_field_errors': ['Invalid email or password']
                    })
                
                logger.info(f"Admin authenticated: {email}")
                data['admin_data'] = admin_data
                return data
                
        except Exception as e:
            logger.error(f"Authentication error for {email}: {str(e)}")
            raise serializers.ValidationError({
                'non_field_errors': ['Authentication service unavailable']
            })


class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.CharField(required=True)

    def validate_email(self, value):
        value = value.lower().strip()
        try:
            validate_email(value)
            return value
        except ValidationError:
            raise serializers.ValidationError("Enter a valid email address")

class VerifyOTPSerializer(serializers.Serializer):
    otp = serializers.CharField(
        required=True, 
        min_length=6, 
        max_length=6,
        help_text="6-digit OTP"
    )

    def validate_otp(self, value):
        if not value.isdigit():
            raise serializers.ValidationError("OTP must be 6 digits")
        return value

class ResetPasswordSerializer(serializers.Serializer):
    new_password = serializers.CharField(
        required=True,
        write_only=True,
        min_length=8,
        help_text="New password (min 8 chars)"
    )
    confirm_password = serializers.CharField(
        required=True,
        write_only=True,
        help_text="Must match new password"
    )

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({
                'confirm_password': ["Passwords don't match"]
            })
        
        password = data['new_password']
        has_upper = bool(re.search(r'[A-Z]', password))
        has_lower = bool(re.search(r'[a-z]', password))
        has_number = bool(re.search(r'[0-9]', password))
        has_symbol = bool(re.search(r'[^A-Za-z0-9]', password))
        fulfilled = sum([has_upper, has_lower, has_number, has_symbol])

        if len(password) < 8 or fulfilled < 3:
            raise serializers.ValidationError({
                'new_password': ["Password too weak - must include at least 3 of these: uppercase, lowercase, number, or symbol, and be at least 8 characters."]
            })
        
        return data