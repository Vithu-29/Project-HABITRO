from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Achievement , UserAchievement
from rewards.models import Reward
from game.models import GameStats

@receiver(post_save, sender=GameStats)
def check_game_achievements(sender, instance, **kwargs):
    user = instance.user
    if instance.games_won >= 1:
        achievement = Achievement.objects.get(unlock_condition='first_win')
        UserAchievement.objects.update_or_create(
            user=user,
            achievement=achievement,
            defaults={'unlocked': True}
        )

@receiver(post_save, sender=Reward)
def check_streak_achievements(sender, instance, **kwargs):
    user = instance.user
    if instance.daily_streak >= 3:
        achievement = Achievement.objects.get(unlock_condition='3_day_streak')
        UserAchievement.objects.update_or_create(
            user=user,
            achievement=achievement,
            defaults={'unlocked': True}
        )