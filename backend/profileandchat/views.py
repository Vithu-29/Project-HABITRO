from rest_framework.decorators import api_view, permission_classes,parser_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Friendship, Message, UserProfile
from app_frontend.models import CustomUser
from .serializers import UserSearchResultSerializer, FriendshipSerializer, MessageSerializer
from django.db.models import Q, Count, Max
from django.db import transaction


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def search_user(request):
    query = request.data.get('query')
    user = request.user

    try:
        target_user = CustomUser.objects.get(Q(email=query) | Q(phone_number=query))
        if target_user == user:
            return Response({'error': 'Cannot add yourself'}, status=400)

        return Response(UserSearchResultSerializer(target_user).data)
    except CustomUser.DoesNotExist:
        return Response({'error': 'User not found'}, status=404)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_friend(request):
    user = request.user
    friend_id = request.data.get('friend_id')
    if not friend_id:
        return Response({'error': 'friend_id required'}, status=400)

    try:
        friend = CustomUser.objects.get(id=friend_id)
    except CustomUser.DoesNotExist:
        return Response({'error': 'User not found'}, status=404)

    if Friendship.objects.filter(user=user, friend=friend).exists():
        return Response({'message': 'Already friends'})

    Friendship.objects.create(user=user, friend=friend)
    Friendship.objects.create(user=friend, friend=user)

    return Response({'message': 'Friend added'})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_friends(request):
    user = request.user
    friends = Friendship.objects.filter(user=user).select_related('friend')
    data = []

    for f in friends:
        friend = f.friend

        # Get last message between user and friend (visible to current user)
        last_msg = Message.objects.filter(
            Q(sender=user, receiver=friend, is_deleted_by_sender=False) | 
            Q(sender=friend, receiver=user, is_deleted_by_receiver=False)
        ).order_by('-timestamp').first()

        # Count unread messages from friend to user
        unread_count = Message.objects.filter(
            sender=friend,
            receiver=user,
            is_read=False,
            is_deleted_by_receiver=False
        ).count()

        data.append({
            'id': friend.id,
            'name': friend.full_name,
            'profile_pic': friend.profile.profile_pic.url if friend.profile.profile_pic else None,
            'last_message': last_msg.text if last_msg else None,
            'last_sender_id': last_msg.sender.id if last_msg else None,
            'timestamp': last_msg.timestamp.isoformat() if last_msg else None,
            'unread_count': unread_count,
        })

    # Sort by timestamp (most recent first)
    data.sort(key=lambda x: x['timestamp'] or '', reverse=True)
    return Response(data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_or_create_room(request):
    user = request.user
    friend_id = request.data.get('friend_id')

    if not friend_id:
        return Response({'error': 'friend_id is required'}, status=400)

    try:
        friend = CustomUser.objects.get(id=friend_id)
    except CustomUser.DoesNotExist:
        return Response({'error': 'Friend not found'}, status=404)

    ids = sorted([str(user.id), str(friend.id)])
    room_id = f"{ids[0]}_{ids[1]}"

    return Response({'room_id': room_id})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def fetch_messages(request):
    user = request.user
    room_id = request.data.get('room_id')
    page = int(request.data.get('page', 1))
    page_size = int(request.data.get('page_size', 50))

    if not room_id:
        return Response({'error': 'room_id required'}, status=400)

    try:
        id1, id2 = map(int, room_id.split('_'))
    except:
        return Response({'error': 'Invalid room_id format'}, status=400)

    # Get messages visible to current user
    messages_query = Message.objects.filter(
        Q(sender_id=id1, receiver_id=id2) |
        Q(sender_id=id2, receiver_id=id1)
    )

    # Filter messages based on user's deletion status
    if user.id == id1:
        messages_query = messages_query.filter(
            Q(sender_id=id1, is_deleted_by_sender=False) |
            Q(receiver_id=id1, is_deleted_by_receiver=False)
        )
    else:
        messages_query = messages_query.filter(
            Q(sender_id=id2, is_deleted_by_sender=False) |
            Q(receiver_id=id2, is_deleted_by_receiver=False)
        )

    # Order by timestamp descending for pagination (latest first)
    messages = messages_query.order_by('-timestamp')
    
    # Pagination
    start = (page - 1) * page_size
    end = start + page_size
    paginated_messages = messages[start:end]
    
    # Reverse to show oldest first in the response
    paginated_messages = list(paginated_messages)[::-1]

    # Mark messages as read if user is receiver
    other_user_id = id2 if user.id == id1 else id1
    Message.objects.filter(
        sender_id=other_user_id,
        receiver=user,
        is_read=False
    ).update(is_read=True)

    serialized_messages = MessageSerializer(paginated_messages, many=True).data
    
    return Response({
        'messages': serialized_messages,
        'has_more': messages.count() > end,
        'total_count': messages.count()
    })


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_message(request):
    user = request.user
    message_id = request.data.get('message_id')

    if not message_id:
        return Response({'error': 'message_id required'}, status=400)

    try:
        message = Message.objects.get(id=message_id)
        
        # Check if user is sender or receiver
        if message.sender == user:
            message.is_deleted_by_sender = True
        elif message.receiver == user:
            message.is_deleted_by_receiver = True
        else:
            return Response({'error': 'Unauthorized'}, status=403)

        message.save()

        # If both users deleted, physically delete the message
        if message.is_deleted_by_sender and message.is_deleted_by_receiver:
            message.delete()

        return Response({'message': 'Message deleted successfully'})
    except Message.DoesNotExist:
        return Response({'error': 'Message not found'}, status=404)


from rest_framework.parsers import MultiPartParser, FormParser
from .serializers import UserProfileSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_profile(request):
    user = request.user
    try:
        profile = user.profile
        return Response(UserProfileSerializer(profile).data)
    except UserProfile.DoesNotExist:
        return Response({'error': 'Profile not found'}, status=404)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def update_profile(request):
    user = request.user
    try:
        profile = user.profile
    except UserProfile.DoesNotExist:
        return Response({'error': 'Profile not found'}, status=404)

    data = request.data.copy()
    serializer = UserProfileSerializer(profile, data=data, partial=True)
    
    if serializer.is_valid():
        try:
            with transaction.atomic():  # Ensure atomic update
                # Save profile data first
                serializer.save()
                
                # Synchronize fields with CustomUser
                user.full_name = profile.full_name
                user.email = profile.email
                user.phone_number = profile.phone_number
                user.save()
                
        except Exception as e:
            return Response({'error': str(e)}, status=400)
            
        return Response(serializer.data)
    return Response(serializer.errors, status=400)


# views.py

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .leaderboard_service import calculate_completion_rate
from .models import UserProfile
from django.contrib.auth import get_user_model

User = get_user_model()

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def leaderboard_view(request):
    period = request.GET.get('period', 'all_time')
    current_user = request.user

    # Get ranked user list
    users = calculate_completion_rate(period)
    top_users = users[:100]

    leaderboard_data = []
    current_user_data = None
    current_user_rank = None

    # Loop to construct leaderboard and find current user's rank
    for index, user in enumerate(users, start=1):
        user_profile_url = None
        try:
            if hasattr(user, 'profile') and user.profile.profile_pic:
                user_profile_url = user.profile.profile_pic.url
        except UserProfile.DoesNotExist:
            pass

        user_data = {
            'rank': index,
            'user_id': user.id,
            'full_name': user.full_name,
            'completion_rate': user.completion_rate,
            'profile_pic_url': user_profile_url
        }

        if index <= 100:
            leaderboard_data.append(user_data)

        if user.id == current_user.id:
            current_user_rank = index
            current_user_data = user_data

    response = {
        'top_100': leaderboard_data
    }

    if current_user_rank and current_user_rank > 100:
        response['current_user'] = current_user_data

    return Response(response)