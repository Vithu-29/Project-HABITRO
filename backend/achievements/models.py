from django.db import models

class Achievement(models.Model):
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='achievements/', blank=True)
    unlock_condition = models.CharField(max_length=50, blank=True)  # Add this

    def __str__(self):
        return self.title
    
class UserAchievement(models.Model):
    user_id = models.IntegerField()  # Replace with ForeignKey after auth
    achievement = models.ForeignKey(Achievement, on_delete=models.CASCADE)
    unlocked = models.BooleanField(default=False)
    is_collected = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user_id} - {self.achievement.title}"
