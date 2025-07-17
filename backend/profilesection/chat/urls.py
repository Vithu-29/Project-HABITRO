from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
from .views import (
    UserList,
    UserViewSet,
    UserProfileViewSet,
    FriendshipViewSet,
    ChatViewSet,
    LeaderboardViewSet,
    NotificationViewSet,
    EditProfileViewSet
)

router = DefaultRouter()
router.register(r'users', views.UserViewSet, basename='user')
router.register(r'profiles', UserProfileViewSet, basename='profile')
router.register(r'friendships', FriendshipViewSet, basename='friendship')
router.register(r'chat', ChatViewSet, basename='chat')
router.register(r'leaderboard', LeaderboardViewSet, basename='leaderboard')
router.register(r'notifications', NotificationViewSet, basename='notification')

edit_profile = EditProfileViewSet.as_view({
    'get': 'me',
    'put': 'me',
})

urlpatterns = [
    path('', include(router.urls)),
    path('profile/me/', edit_profile, name='edit-profile'),
    path('api/users/', UserList.as_view(), name='user-list'),
    path('users/me/', UserViewSet.as_view({'get': 'me'}), name='user-me'),
    path('users/search/', UserViewSet.as_view({'get': 'search'}), name='user-search'),
    path('profiles/update_points/', UserProfileViewSet.as_view({'patch': 'update_points'}), name='profile-update-points'),
    path('friendships/<int:pk>/accept/', FriendshipViewSet.as_view({'post': 'accept'}), name='friendship-accept'),
    path('friendships/<int:pk>/reject/', FriendshipViewSet.as_view({'post': 'reject'}), name='friendship-reject'),
    path('chat/conversations/', ChatViewSet.as_view({'get': 'conversations'}), name='chat-conversations'),
    path('chat/with_user/', ChatViewSet.as_view({'get': 'with_user'}), name='chat-with-user'),
    path('leaderboard/around_me/', LeaderboardViewSet.as_view({'get': 'around_me'}), name='leaderboard-around-me'),
    path('notifications/mark_all_read/', NotificationViewSet.as_view({'post': 'mark_all_read'}), name='notification-mark-all-read'),
]
