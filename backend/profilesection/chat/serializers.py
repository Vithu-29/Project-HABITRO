from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    UserProfile,
    Friendship,
    ChatMessage,
    Leaderboard,
    Notification
)

# USER PROFILE

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'name',        # ✅ Your custom field
            'email',       # ✅ Your custom field
            'streak',
            'total_points',
            'weekly_points',
            'last_active',
            'avatar',
            'date_of_birth',
            'gender',
            'phone_number',
            'is_private'
        ]
        read_only_fields = ['last_active']



# USER


class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(required=False)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'profile']
        extra_kwargs = {
            'password': {'write_only': True},
            'email': {'required': True}
        }

    def create(self, validated_data):
        profile_data = validated_data.pop('profile', None)
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data.get('password'),
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', '')
        )
        UserProfile.objects.create(
            user=user,
            username=user.username,
            email=user.email,
            **(profile_data or {})
        )
        return user

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile', {})
        
        # Update base User fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # Update or create UserProfile fields
        profile = getattr(instance, 'profile', None)
        if profile:
            for attr, value in profile_data.items():
                setattr(profile, attr, value)

            # Keep username/email in sync with User model
            profile.username = instance.username
            profile.email = instance.email
            profile.save()
        elif profile_data:
            UserProfile.objects.create(user=instance, **profile_data)

        return instance

# MINI USER (Used in chats, etc.)

class MiniUserSerializer(serializers.ModelSerializer):
    avatar = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'avatar']

    def get_avatar(self, obj):
        if hasattr(obj, 'profile') and obj.profile.avatar:
            return obj.profile.avatar.url
        return None


# FRIENDSHIP

class FriendshipSerializer(serializers.ModelSerializer):
    requester_username = serializers.CharField(source='requester.username', read_only=True)
    receiver_username = serializers.CharField(source='receiver.username', read_only=True)
    requester_avatar = serializers.SerializerMethodField()
    receiver_avatar = serializers.SerializerMethodField()

    class Meta:
        model = Friendship
        fields = [
            'id',
            'requester', 'requester_username', 'requester_avatar',
            'receiver', 'receiver_username', 'receiver_avatar',
            'status', 'created_at', 'updated_at'
        ]
        read_only_fields = ['requester', 'created_at', 'updated_at']

    def get_requester_avatar(self, obj):
        return getattr(obj.requester.profile.avatar, 'url', None)

    def get_receiver_avatar(self, obj):
        return getattr(obj.receiver.profile.avatar, 'url', None)


# CHAT MESSAGES

class ChatMessageSerializer(serializers.ModelSerializer):
    sender_id = serializers.PrimaryKeyRelatedField(source='sender', read_only=True)
    sender_username = serializers.CharField(source='sender.username', read_only=True)
    sender_avatar = serializers.SerializerMethodField()
    receiver_id = serializers.PrimaryKeyRelatedField(source='receiver', read_only=True)
    receiver_username = serializers.CharField(source='receiver.username', read_only=True)
    timestamp = serializers.DateTimeField(format='%Y-%m-%d %H:%M:%S', read_only=True)

    class Meta:
        model = ChatMessage
        fields = [
            'id',
            'sender_id', 'sender_username', 'sender_avatar',
            'receiver_id', 'receiver_username',
            'message', 'timestamp', 'is_read'
        ]
        read_only_fields = ['is_read']

    def get_sender_avatar(self, obj):
        return getattr(obj.sender.profile.avatar, 'url', None)


# LEADERBOARD

class LeaderboardSerializer(serializers.ModelSerializer):
    user_id = serializers.PrimaryKeyRelatedField(source='user', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    avatar = serializers.SerializerMethodField()
    period_display = serializers.CharField(source='get_period_display', read_only=True)
    avatar = serializers.SerializerMethodField()

    class Meta:
        model = Leaderboard
        fields = [
            'user_id', 'username', 'avatar',
            'period', 'period_display',
            'score', 'rank', 'updated_at'
        ]
        read_only_fields = ['rank', 'updated_at']

    def get_avatar(self, obj):
        try:
            # Check if profile exists and has avatar
            if hasattr(obj.user, 'profile') and obj.user.profile.avatar:
                return obj.user.profile.avatar.url
        except UserProfile.DoesNotExist:
            pass
        return None

# NOTIFICATIONS

class NotificationSerializer(serializers.ModelSerializer):
    type_display = serializers.CharField(source='get_notification_type_display', read_only=True)
    created_at = serializers.DateTimeField(format='%Y-%m-%d %H:%M:%S', read_only=True)

    class Meta:
        model = Notification
        fields = [
            'id',
            'notification_type', 'type_display',
            'message', 'related_id',
            'is_read', 'created_at'
        ]
        read_only_fields = ['is_read']
