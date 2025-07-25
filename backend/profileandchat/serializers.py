from rest_framework import serializers
from .models import Message, Friendship
from app_frontend.models import CustomUser  # adjust if needed

class MessageSerializer(serializers.ModelSerializer):
    message = serializers.SerializerMethodField()
    sender_id = serializers.IntegerField(source='sender.id')
    receiver_id = serializers.IntegerField(source='receiver.id')
    message_id = serializers.IntegerField(source='id')

    class Meta:
        model = Message
        fields = ['message_id', 'id', 'message', 'sender_id', 'receiver_id', 'timestamp', 'is_read']

    def get_message(self, obj):
        """Return decrypted message text"""
        return obj.text

class FriendshipSerializer(serializers.ModelSerializer):
    class Meta:
        model = Friendship
        fields = '__all__'

class UserSearchResultSerializer(serializers.ModelSerializer):
    profile_pic = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = ['id', 'full_name', 'email', 'phone_number', 'profile_pic']

    def get_profile_pic(self, obj):
        try:
            return obj.profile.profile_pic.url if obj.profile.profile_pic else None
        except:
            return None
        
from rest_framework import serializers
from .models import UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source='user.email', read_only=True)
    
    class Meta:
        model = UserProfile
        fields = ['full_name', 'phone_number', 'dob', 'gender', 'profile_pic', 'email']
        extra_kwargs = {
            'profile_pic': {'required': False}
        }