from rest_framework import serializers
from .models import AdminUser
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
import re

class AdminRegisterSerializer(serializers.Serializer):
    email = serializers.CharField(required=True)
    password = serializers.CharField(
        write_only=True,
        required=True,
        min_length=8,
        style={'input_type': 'password'}
    )

    def validate_email(self, value):
        value = value.lower().strip()
        
        # Basic email format validation
        try:
            validate_email(value)
        except ValidationError:
            raise serializers.ValidationError("Enter a valid email address (e.g., example@gmail.com)")
        
        # Validate email pattern (must be @gmail.com)
        if not re.match(r'^[\w\.-]+@gmail\.com$', value):
            raise serializers.ValidationError("Only Gmail addresses are allowed (e.g., example@gmail.com)")
        
        # Check if email exists
        if AdminUser.objects.filter(email=value).exists():
            raise serializers.ValidationError("This email is already registered")
            
        return value

    def create(self, validated_data):
        return AdminUser.create_admin(
            email=validated_data['email'],
            password=validated_data['password']
        )