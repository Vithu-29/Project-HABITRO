import uuid
from django.db import models
from datetime import date
from django.contrib.auth.models import User


class Task(models.Model):

    habit_id = models.ForeignKey('Habit', on_delete=models.CASCADE, related_name="tasks")
    task = models.TextField()
    isCompleted = models.BooleanField(default=False)
    date = models.DateField(default=date.today) # New field to track the day for this task
    created_at = models.DateTimeField(auto_now_add=True)  
    
   ## habit_id = models.CharField(max_length=100)  # Unique identifier for the habit
   ## task_id = models.PositiveIntegerField()      # Sequential ID for each task
   ## day = models.PositiveIntegerField()          # Day number (e.g., Day 1, Day 2)
   ## description = models.TextField()
   ## is_completed = models.BooleanField(default=False)
   ## created_at = models.DateTimeField(auto_now_add=True)

    ##class Meta:
    ##    unique_together = ('habit_id', 'task_id')
    ##    ordering = ['task_id']


class Habit(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    type = models.CharField(max_length=20)  # "good" or "bad"
    created_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return f"{self.name}"
    

class UserCoins(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    balance = models.PositiveIntegerField(default=0)
    last_updated = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s coins: {self.balance}"

class CoinTransaction(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.IntegerField()
    reason = models.CharField(max_length=100)  # e.g., "task_completion"
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username}: {self.amount} coins ({self.reason})"