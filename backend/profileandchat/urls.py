from django.urls import path
from . import views

urlpatterns = [
    path('search-user/', views.search_user),
    path('add-friend/', views.add_friend),
    path('list-friends/', views.list_friends),
    path('get-or-create-room/', views.get_or_create_room),
    path('fetch-messages/', views.fetch_messages), 
    path('get-profile/', views.get_profile, name='get_profile'),
    path('update-profile/', views.update_profile, name='update_profile'),
    path('leaderboard/', views.leaderboard_view, name='leaderboard'),
    path('delete-messages/', views.delete_message, name='delete_message'),
]
