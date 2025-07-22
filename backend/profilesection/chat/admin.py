# Register your models here.
from django.contrib import admin
from .models import UserProfile, Friendship, ChatMessage, Leaderboard, Notification
from .models import User

admin.site.register(UserProfile)
admin.site.register(Friendship)
admin.site.register(ChatMessage)
admin.site.register(Leaderboard)
admin.site.register(Notification)

class UserAdmin(admin.ModelAdmin):
    list_display = ('name', 'username')  # Display name and username in the list view
    search_fields = ('name', 'username')