from django.contrib import admin
from .models import CustomUser
from .models import Challenge, ChallengeHabit, UserChallenge, UserChallengeHabit

# Register your models here.
admin.site.register(CustomUser)

@admin.register(Challenge)
class ChallengeAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'duration_days', 'is_active')
    list_filter = ('category', 'is_active')
    search_fields = ('title', 'description')

@admin.register(ChallengeHabit)
class ChallengeHabitAdmin(admin.ModelAdmin):
    list_display = ('title', 'challenge', 'frequency')
    list_filter = ('challenge', 'frequency')
    search_fields = ('title', 'description')

@admin.register(UserChallenge)
class UserChallengeAdmin(admin.ModelAdmin):
    list_display = ('user', 'challenge', 'start_date', 'is_active')
    list_filter = ('is_active', 'challenge')
    search_fields = ('user__email', 'challenge__title')

@admin.register(UserChallengeHabit)
class UserChallengeHabitAdmin(admin.ModelAdmin):
    list_display = ('user_challenge', 'habit', 'is_completed', 'completed_date')
    list_filter = ('is_completed', 'habit')
    search_fields = ('user_challenge__user__email', 'habit__title')
