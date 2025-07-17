from django.db import models
from django.contrib.auth.models import User
from django.conf import settings

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    name = models.CharField(max_length=255, null=True, blank=True)
    bio = models.TextField(blank=True, null=True)
    streak = models.PositiveIntegerField(default=0)
    total_points = models.PositiveIntegerField(default=0)
    weekly_points = models.PositiveIntegerField(default=0)
    last_active = models.DateTimeField(auto_now=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True, default='default_avatar.png')
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=10, choices=[('Male', 'Male'), ('Female', 'Female'), ('Other', 'Other')], blank=True)
    email = models.EmailField(blank=True)
    phone_number = models.CharField(max_length=20, blank=True)
    is_private = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.username}'s Profile"

    def update_points(self, points_to_add):
        self.total_points += points_to_add
        self.weekly_points += points_to_add
        self.save()

    def avatar_url(self):
        if self.avatar and self.avatar.name:
            try:
                return self.avatar.url
            except ValueError:
                pass
        return f"{settings.MEDIA_URL}default_avatar.png"


class Friendship(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
    ]

    requester = models.ForeignKey(User, related_name='friend_requests_sent', on_delete=models.CASCADE)
    receiver = models.ForeignKey(User, related_name='friend_requests_received', on_delete=models.CASCADE)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('requester', 'receiver')
        verbose_name_plural = 'Friendships'

    def __str__(self):
        return f"{self.requester.username} → {self.receiver.username} ({self.status})"


class ChatMessage(models.Model):
    sender = models.ForeignKey(User, related_name='sent_messages', on_delete=models.CASCADE)
    receiver = models.ForeignKey(User, related_name='received_messages', on_delete=models.CASCADE)
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['sender', 'receiver']),
            models.Index(fields=['timestamp']),
        ]

    def __str__(self):
        return f"{self.sender.username} → {self.receiver.username}: {self.message[:30]}"

    def mark_as_read(self):
        if not self.is_read:
            self.is_read = True
            self.save()


class Leaderboard(models.Model):
    PERIOD_CHOICES = [
        ('daily', 'Daily'),
        ('weekly', 'Weekly'),
        ('monthly', 'Monthly'),
        ('all_time', 'All Time'),
    ]

    user = models.ForeignKey(User, related_name='leaderboard_entries', on_delete=models.CASCADE)
    period = models.CharField(max_length=10, choices=PERIOD_CHOICES, default='weekly')
    score = models.PositiveIntegerField(default=0)
    rank = models.PositiveIntegerField(blank=True, null=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'period')
        ordering = ['period', '-score']

    def __str__(self):
        return f"{self.user.username} ({self.period}): {self.score} points (Rank {self.rank})"


class Notification(models.Model):
    TYPE_CHOICES = [
        ('friend_request', 'Friend Request'),
        ('message', 'New Message'),
        ('points', 'Points Update'),
    ]

    user = models.ForeignKey(User, related_name='notifications', on_delete=models.CASCADE)
    notification_type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    message = models.CharField(max_length=255)
    related_id = models.PositiveIntegerField(blank=True, null=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username}: {self.notification_type} - {self.message}"
