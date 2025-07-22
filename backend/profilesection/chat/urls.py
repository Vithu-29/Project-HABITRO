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
    EditProfileViewSet,
    AppearanceSettingsView
)

# DRF Router registration
router = DefaultRouter()
router.register(r'users', views.UserViewSet, basename='user')  # User view for /users/
router.register(r'profiles', UserProfileViewSet, basename='profile')
router.register(r'friendships', FriendshipViewSet, basename='friendship')
router.register(r'chat', ChatViewSet, basename='chat')  # Chat view for /chat/
router.register(r'leaderboard', LeaderboardViewSet, basename='leaderboard')
router.register(r'notifications', NotificationViewSet, basename='notification')

# Custom views for profile editing
edit_profile = EditProfileViewSet.as_view({
    'get': 'me',
    'put': 'me',
})

urlpatterns = [
    # Router endpoints
    path('', include(router.urls)),

    # Custom profile editing
    path('profile/me/', edit_profile, name='edit-profile'),

    # Custom user endpoints
    path('api/users/', UserList.as_view(), name='user-list'),
    path('users/me/', UserViewSet.as_view({'get': 'me'}), name='user-me'),
    path('users/search/', UserViewSet.as_view({'get': 'search'}), name='user-search'),

    # Profile actions
    path('profiles/update_points/', UserProfileViewSet.as_view({'patch': 'update_points'}), name='profile-update-points'),

    # Friendship actions
    path('friendships/<int:pk>/accept/', FriendshipViewSet.as_view({'post': 'accept'}), name='friendship-accept'),
    path('friendships/<int:pk>/reject/', FriendshipViewSet.as_view({'post': 'reject'}), name='friendship-reject'),

    # Chat actions
    path('chat/conversations/', ChatViewSet.as_view({'get': 'conversations'}), name='chat-conversations'),
    path('chat/with_user/', ChatViewSet.as_view({'get': 'with_user'}), name='chat-with-user'),

    # Leaderboard actions
    path('leaderboard/around_me/', LeaderboardViewSet.as_view({'get': 'around_me'}), name='leaderboard-around-me'),

    # Notification actions
    path('notifications/mark_all_read/', NotificationViewSet.as_view({'post': 'mark_all_read'}), name='notification-mark-all-read'),

    path('api/appearance/', AppearanceSettingsView.as_view(), name='appearance-settings'),
]
