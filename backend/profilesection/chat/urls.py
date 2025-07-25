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
from django.core.exceptions import ObjectDoesNotExist

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
    width, height = 100, 100
    img = Image.new('RGB', (width, height), color=(255, 255, 255))
    d = ImageDraw.Draw(img)
    text = ''.join(random.choices(string.ascii_uppercase, k=2))
    d.text((10, 25), text, fill=(0, 0, 0))

    image_io = BytesIO()
    img.save(image_io, 'PNG')
    image_io.seek(0)

    avatar_name = f"avatars/{''.join(random.choices(string.ascii_lowercase + string.digits, k=8))}.png"
    avatar_file = InMemoryUploadedFile(image_io, None, avatar_name, 'image/png', image_io.getbuffer().nbytes, None)

    file_path = default_storage.save(avatar_name, avatar_file)
    return file_path

class AppearanceSettingsView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user.profile

class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

class UserList(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        users = User.objects.exclude(id=request.user.id)
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)
    
class UserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.filter(is_staff=True)
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['GET'])
    def me(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['GET'])
    def search(self, request):
        query = request.query_params.get('q', '')
        if query:
            users = User.objects.filter(username__icontains=query, is_staff=False)
            serializer = UserSerializer(users, many=True)
            return Response(serializer.data)
        return Response({"error": "Please provide a 'q' query parameter to search."},
                        status=400)

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

class FriendshipViewSet(viewsets.ModelViewSet):
    serializer_class = FriendshipSerializer
    permission_classes = [IsAuthenticated]

    def create(self, request):
        receiver_id = request.data.get('receiver_id')
        if receiver_id == request.user.id:
            return Response({'error': 'Cannot send friend request to yourself'},
                            status=status.HTTP_400_BAD_REQUEST)

        friendship, created = Friendship.objects.get_or_create(
            requester=request.user,
            receiver_id=receiver_id,
            defaults={'status': 'pending'}
        )

        if not created:
            return Response({'error': 'Friend request already exists'},
                            status=status.HTTP_400_BAD_REQUEST)

        receiver_user = User.objects.get(id=receiver_id)
        receiver_user.is_staff = True
        receiver_user.save()

        Notification.objects.create(
            user_id=receiver_id,
            notification_type='friend_request',
            message=f'{request.user.username} sent you a friend request',
            related_id=friendship.id
        )

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

class LeaderboardViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = LeaderboardSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        period = self.request.query_params.get('period', 'weekly')
        page = int(self.request.query_params.get('page', 1))
        page_size = 100
        start = (page - 1) * page_size
        end = start + page_size
        return Leaderboard.objects.filter(
            period=period
        ).select_related('user__profile').order_by('-score')[start:end]

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        data = serializer.data
        
        for entry in data:
            avatar_url = entry.get('avatar')
            if avatar_url:
                entry['avatar'] = request.build_absolute_uri(avatar_url)
            else:
                user_profile = entry.get('user', {}).get('profile', None)
                if user_profile and not user_profile.get('avatar'):
                    avatar_path = generate_avatar()
                    user_profile.avatar = avatar_path
                    user_profile.save()
                    entry['avatar'] = request.build_absolute_uri(settings.MEDIA_URL + avatar_path)
        
        return Response(data)

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
                user = request.user

                profile_data = request.data.get('profile', {})
                avatar = profile_data.get('avatar', None)

                if avatar:
                    old_avatar = user.profile.avatar
                    if old_avatar:
                        old_avatar_path = os.path.join(settings.MEDIA_ROOT, old_avatar.name)
                        if default_storage.exists(old_avatar_path):
                            default_storage.delete(old_avatar_path)

                    user.profile.avatar = avatar
                    user.profile.save()

                serializer.save()

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
