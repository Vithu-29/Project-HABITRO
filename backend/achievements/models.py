from django.db import models
from django.contrib.auth import get_user_model

class Achievement(models.Model):
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='achievements/', blank=True)
    unlock_condition = models.CharField(max_length=50, blank=True)

    def __str__(self):
        return self.title
    
class UserAchievement(models.Model):
    user = models.ForeignKey(
        get_user_model(),
        on_delete=models.CASCADE,
        related_name='user_achievements',
    )
    achievement = models.ForeignKey(Achievement, on_delete=models.CASCADE)
    unlocked = models.BooleanField(default=False)
    is_collected = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user_id} - {self.achievement.title}"
