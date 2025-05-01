from rest_framework import serializers
from .models import CustomUser

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    class Meta:
        model = CustomUser
        fields = ['email', 'phone_number', 'full_name', 'password', 'confirm_password']

    def validate(self, data):
        email = data.get('email')
        phone_number = data.get('phone_number')

        # Ensure either email or phone_number is provided, but not both
        if not email and not phone_number:
            raise serializers.ValidationError("You must provide either an email or a phone number.")
        if email and phone_number:
            raise serializers.ValidationError("You can only provide either an email or a phone number, not both.")

        # Ensure passwords match
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError({"confirm_password": "Passwords do not match."})

        return data

    def create(self, validated_data):
        validated_data.pop('confirm_password')  # Remove confirm_password before saving
        user = CustomUser.objects.create_user(
            email=validated_data.get('email'),
            phone_number=validated_data.get('phone_number'),
            full_name=validated_data['full_name'],
            password=validated_data['password']
        )
        return user