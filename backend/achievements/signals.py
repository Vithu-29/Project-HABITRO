from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Achievement , UserAchievement
from rewards.models import Reward
from game.models import GameStats

@receiver(post_save, sender=GameStats)
def check_game_achievements(sender, instance, **kwargs):
    user_id = instance.user_id
    # Example: Check for "first_win" achievement
    if instance.games_won >= 1:
        achievement = Achievement.objects.get(unlock_condition='first_win')
        UserAchievement.objects.update_or_create(
            user_id=user_id,
            achievement=achievement,
            defaults={'unlocked': True}  # Unlock if condition met
        )

@receiver(post_save, sender=Reward)
def check_streak_achievements(sender, instance, **kwargs):
    user_id = instance.user_id
    # Example: Check for "3_day_streak" achievement
    if instance.daily_streak >= 3:
        achievement = Achievement.objects.get(unlock_condition='3_day_streak')
        UserAchievement.objects.update_or_create(
            user_id=user_id,
            achievement=achievement,
            defaults={'unlocked': True}
        )