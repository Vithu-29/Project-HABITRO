from django.db import models

class GameStats(models.Model):
    user_id = models.IntegerField(default=1)  # Hardcoded for now
    games_won = models.PositiveIntegerField(default=0)
    best_time = models.PositiveIntegerField(default=0)  # In seconds

    class Meta:
        verbose_name_plural = "Game Statistics"

    def __str__(self):
        return f"User {self.user_id} Game Stats"