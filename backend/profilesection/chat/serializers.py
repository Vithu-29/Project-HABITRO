from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    UserProfile,
    Friendship,
    ChatMessage,
    Leaderboard,
    Notification
)
from django.core.files.base import ContentFile
import random
import string
from io import BytesIO
from PIL import Image, ImageDraw, ImageFont
from django.core.files.storage import default_storage  # Import default_storage

# USER PROFILE
class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'name',        # Your custom field
            'email',       # Your custom field
            'streak',
            'total_points',
            'weekly_points',
            'last_active',
            'avatar',
            'date_of_birth',
            'gender',
            'phone_number',
            'is_private',
            'theme_preference',
            'font_size_preference',
        ]
        read_only_fields = ['last_active']


# USER
class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(required=False)
    name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'profile', 'name', 'is_staff']  # Added 'is_staff'
        extra_kwargs = {
            'password': {'write_only': True},
            'email': {'required': True}
        }

    def get_name(self, obj):
        # Combine first name and last name to create a full name
        return f"{obj.first_name} {obj.last_name}" if obj.first_name and obj.last_name else "No Name"

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
        # If no avatar, generate one
        return self.generate_random_avatar(obj.user)

    def generate_random_avatar(self, user):
        """Generate and save a random avatar image for the user."""
        # Ensure the user has a profile, if not, create it
        if not hasattr(user, 'profile'):
            # Create a new UserProfile if not exists
            user_profile = UserProfile.objects.create(user=user)
        else:
            user_profile = user.profile

        # Image dimensions (increased for larger text)
        width, height = 150, 150
        img = Image.new('RGB', (width, height))  # Create the image

        # Random background color (bright and vibrant)
        background_color = tuple(random.choices(range(180, 256), k=3))  # Ranges from 180 to 255 for bright colors
        img.paste(Image.new('RGB', (width, height), background_color))

        d = ImageDraw.Draw(img)

        # Set font size larger for better visibility
        try:
            font = ImageFont.truetype("arial.ttf", 70)  # Use a very large font size for better visibility
        except IOError:
            font = ImageFont.load_default()  # Fallback if the font is not available

        text = ''.join(random.choices(string.ascii_uppercase, k=2))  # Random 2 letters
        text_width, text_height = d.textsize(text, font=font)

        # Calculate position to center text in the image
        position = ((width - text_width) / 2, (height - text_height) / 2)

        # Random text color (dark color for contrast)
        text_color = tuple(random.choices(range(0, 128), k=3))  # Dark colors for text (low range)

        # Draw text in the generated color
        d.text(position, text, fill=text_color, font=font)

        # Add a circle around the text for better animation/visual
        circle_radius = 70
        circle_x = (width / 2)
        circle_y = (height / 2)

        # Random circle color (contrast with background)
        circle_color = tuple(random.choices(range(0, 128), k=3))  # Dark color for the circle to contrast

        d.ellipse([circle_x - circle_radius, circle_y - circle_radius, 
                  circle_x + circle_radius, circle_y + circle_radius], outline=circle_color, width=5)

        # Save the image to a BytesIO object
        image_io = BytesIO()
        img.save(image_io, 'PNG')
        image_io.seek(0)

        # Save the image as a file in the media folder
        avatar_name = f"avatars/{''.join(random.choices(string.ascii_lowercase + string.digits, k=8))}.png"
        avatar_file = ContentFile(image_io.read(), avatar_name)

        # Save it to Django's media storage and update user profile
        file_path = default_storage.save(avatar_name, avatar_file)
        user_profile.avatar = file_path
        user_profile.save()

        return file_path


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
