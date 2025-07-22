from rest_framework import viewsets, status, mixins
from rest_framework import generics, permissions
from PIL import Image, ImageDraw, ImageFont
import random
import string
from io import BytesIO
from django.core.files.uploadedfile import InMemoryUploadedFile
from django.core.files.storage import default_storage
from rest_framework.views import APIView
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.viewsets import GenericViewSet
from django.http import JsonResponse
from django.contrib.auth.models import User
from django.db.models import Q, F
from django.conf import settings

from .models import (
    User,
    UserProfile,
    Friendship,
    ChatMessage,
    Leaderboard,
    Notification
)
from .serializers import (
    UserSerializer,
    UserProfileSerializer,
    FriendshipSerializer,
    ChatMessageSerializer,
    LeaderboardSerializer,
    NotificationSerializer,
    MiniUserSerializer
)

def generate_avatar():
    """Generate a random avatar image."""
    width, height = 100, 100
    img = Image.new('RGB', (width, height), color=(255, 255, 255))
    d = ImageDraw.Draw(img)
    text = ''.join(random.choices(string.ascii_uppercase, k=2))  # Random text
    d.text((10, 25), text, fill=(0, 0, 0))

    # Save the image to a BytesIO object
    image_io = BytesIO()
    img.save(image_io, 'PNG')
    image_io.seek(0)

    # Save the image as a file in the media folder
    avatar_name = f"avatars/{''.join(random.choices(string.ascii_lowercase + string.digits, k=8))}.png"
    avatar_file = InMemoryUploadedFile(image_io, None, avatar_name, 'image/png', image_io.getbuffer().nbytes, None)

    # Save it to Django's media storage
    file_path = default_storage.save(avatar_name, avatar_file)
    return file_path

class AppearanceSettingsView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        # Return the UserProfile for the current logged-in user
        return self.request.user.profile
    
class UserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.filter(is_staff=True)  # Only non-staff users, adjust as needed
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['GET'])
    def me(self, request):
        """Return the current user's information."""
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['GET'])
    def search(self, request):
        """Search users by username (or other fields)."""
        query = request.query_params.get('q', '')
        if query:
            # Example: search by username containing the query, excluding staff
            users = User.objects.filter(username__icontains=query, is_staff=False)
            serializer = UserSerializer(users, many=True)
            return Response(serializer.data)
        return Response({"error": "Please provide a 'q' query parameter to search."},
                        status=400)

# USER - To fetch the list of users (friends)
class UserList(APIView):
    permission_classes = [IsAuthenticated]  # Ensure the user is authenticated

    def get(self, request):
        # Fetch only users marked as staff in the backend
        staff_users = User.objects.filter(is_staff=False)  # Fetch non-staff users
        serializer = UserSerializer(staff_users, many=True)  # Serialize the users
        return Response(serializer.data)  # Return the serialized data

# USER PROFILE
class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['PATCH'])
    def update_points(self, request):
        points = int(request.data.get('points', 0))
        profile = request.user.profile
        profile.update_points(points)

        entry, _ = Leaderboard.objects.get_or_create(
            user=request.user,
            period='weekly',
            defaults={'score': 0}
        )
        entry.score = F('score') + points
        entry.save()

        return Response({
            'status': 'Points updated',
            'total_points': profile.total_points,
            'weekly_points': profile.weekly_points
        })

# FRIENDSHIP
class FriendshipViewSet(viewsets.ModelViewSet):
    serializer_class = FriendshipSerializer
    permission_classes = [IsAuthenticated]

    def create(self, request):
        receiver_id = request.data.get('receiver_id')
        if receiver_id == request.user.id:
            return Response({'error': 'Cannot send friend request to yourself'},
                            status=status.HTTP_400_BAD_REQUEST)

        # Check if friendship already exists
        friendship, created = Friendship.objects.get_or_create(
            requester=request.user,
            receiver_id=receiver_id,
            defaults={'status': 'pending'}
        )

        if not created:
            return Response({'error': 'Friend request already exists'},
                            status=status.HTTP_400_BAD_REQUEST)

        # Update the receiver's is_staff value to 1
        receiver_user = User.objects.get(id=receiver_id)
        receiver_user.is_staff = True
        receiver_user.save()

        # Send notification to the receiver about the new friend request
        Notification.objects.create(
            user_id=receiver_id,
            notification_type='friend_request',
            message=f'{request.user.username} sent you a friend request',
            related_id=friendship.id
        )

        # Return the friendship data
        serializer = self.get_serializer(friendship)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['POST'])
    def accept(self, request, pk=None):
        friendship = self.get_object()
        if friendship.receiver != request.user:
            return Response({'error': 'Permission denied'},
                            status=status.HTTP_403_FORBIDDEN)

        friendship.status = 'accepted'
        friendship.save()

        Notification.objects.create(
            user=friendship.requester,
            notification_type='friend_request',
            message=f'{request.user.username} accepted your friend request',
            related_id=friendship.id
        )
        return Response({'status': 'Friend request accepted'})

    @action(detail=True, methods=['POST'])
    def reject(self, request, pk=None):
        friendship = self.get_object()
        if friendship.receiver != request.user:
            return Response({'error': 'Permission denied'},
                            status=status.HTTP_403_FORBIDDEN)

        friendship.status = 'rejected'
        friendship.save()
        return Response({'status': 'Friend request rejected'})

# CHAT
class ChatViewSet(viewsets.ModelViewSet):
    serializer_class = ChatMessageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return ChatMessage.objects.filter(
            Q(sender=self.request.user) | Q(receiver=self.request.user)
        ).select_related('sender__profile', 'receiver__profile')

    def perform_create(self, serializer):
        message = serializer.save(sender=self.request.user)
        Notification.objects.create(
            user=message.receiver,
            notification_type='message',
            message=f'New message from {self.request.user.username}',
            related_id=message.id
        )

    @action(detail=False, methods=['GET'])
    def conversations(self, request):
        ids = ChatMessage.objects.filter(
            Q(sender=request.user) | Q(receiver=request.user)
        ).values_list('sender', 'receiver')

        user_ids = set()
        for sid, rid in ids:
            if sid != request.user.id:
                user_ids.add(sid)
            if rid != request.user.id:
                user_ids.add(rid)

        users = User.objects.filter(id__in=user_ids)
        serializer = MiniUserSerializer(users, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['GET'])
    def with_user(self, request):
        user_id = request.query_params.get('user_id')
        if not user_id:
            return Response({'error': 'Missing user_id'}, status=400)

        try:
            other_user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=404)

        messages = ChatMessage.objects.filter(
            Q(sender=request.user, receiver=other_user) |
            Q(sender=other_user, receiver=request.user)
        ).order_by('timestamp')

        ChatMessage.objects.filter(
            sender=other_user,
            receiver=request.user,
            is_read=False
        ).update(is_read=True)

        serializer = self.get_serializer(messages, many=True)
        return Response(serializer.data)

# LEADERBOARD
class LeaderboardViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = LeaderboardSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        period = self.request.query_params.get('period', 'weekly')
        page = int(self.request.query_params.get('page', 1))
        page_size = 100  # 100 players per page
        start = (page - 1) * page_size
        end = start + page_size
        return Leaderboard.objects.filter(
            period=period
        ).select_related('user__profile').order_by('-score')[start:end]

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        data = serializer.data
        
        # Process avatar URLs and save avatars if not present
        for entry in data:
            avatar_url = entry.get('avatar')
            if avatar_url:
                # Build full URL for avatars
                entry['avatar'] = request.build_absolute_uri(avatar_url)
            else:
                # Check if the user has a profile avatar, if not, generate and save one
                user_profile = entry.get('user', {}).get('profile', None)
                if user_profile and not user_profile.get('avatar'):
                    avatar_path = generate_avatar()
                    user_profile.avatar = avatar_path
                    user_profile.save()
                    entry['avatar'] = request.build_absolute_uri(settings.MEDIA_URL + avatar_path)
        
        return Response(data)

# NOTIFICATIONS
class NotificationViewSet(mixins.ListModelMixin,
                          mixins.UpdateModelMixin,
                          GenericViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user).order_by('-created_at')

    @action(detail=False, methods=['POST'])
    def mark_all_read(self, request):
        Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'status': 'All notifications marked as read'})

# EDIT PROFILE VIEWSET
class EditProfileViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]

    def get_serializer(self, *args, **kwargs):
        return UserSerializer(*args, **kwargs)

    @action(detail=False, methods=['GET', 'PUT'])
    def me(self, request):
        if request.method == 'GET':
            serializer = UserSerializer(request.user)
            return Response(serializer.data)

        elif request.method == 'PUT':
            serializer = UserSerializer(request.user, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()

                # Handle nested UserProfile update
                profile_data = request.data.get('profile')
                if profile_data:
                    profile_serializer = UserProfileSerializer(
                        request.user.profile, data=profile_data, partial=True
                    )
                    if profile_serializer.is_valid():
                        profile_serializer.save()
                    else:
                        return Response(profile_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
