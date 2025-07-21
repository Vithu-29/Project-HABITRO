import uuid
from django.db import models
from datetime import date, datetime, timedelta
from django.contrib.auth import get_user_model



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
    user = models.ForeignKey(
        get_user_model(),
        on_delete=models.CASCADE,
        related_name='habits',
        null=True
    )
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    type = models.CharField(max_length=20)  # "good" or "bad"
    duration_days = models.PositiveIntegerField(default=30)
    start_date = models.DateField(default=date.today)
    end_date = models.DateField(null=True, blank=True)
    notification_status = models.BooleanField(default=False)
    reminder_time = models.TimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def save(self, *args, **kwargs):
        if not self.end_date and self.duration_days:
            self.end_date = self.start_date + timedelta(days=self.duration_days)
        super().save(*args, **kwargs)
        
    def __str__(self):
        return f"{self.name}"
