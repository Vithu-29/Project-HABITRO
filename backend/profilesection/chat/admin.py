from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import UserProfile, Friendship, ChatMessage, Leaderboard, Notification

admin.site.register(UserProfile)
admin.site.register(Friendship)
admin.site.register(ChatMessage)
admin.site.register(Leaderboard)
admin.site.register(Notification)