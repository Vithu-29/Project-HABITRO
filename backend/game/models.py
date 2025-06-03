from django.db import models
from django.conf import settings
from django.contrib.auth import get_user_model

class GameStats(models.Model):
    user = models.ForeignKey(
        get_user_model(),
        on_delete=models.CASCADE,
        related_name='game_stats',
        null=True
    ) 
    games_won = models.PositiveIntegerField(default=0)
    best_time = models.PositiveIntegerField(default=0) #in seconds

    class Meta:
        verbose_name_plural = "Game Statistics"

    def __str__(self):
        return f"User {self.user_id} Game Stats"