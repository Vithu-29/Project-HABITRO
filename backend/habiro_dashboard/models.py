from django.db import models


class User(models.Model):
    STATUS_CHOICES = (
        ('active', 'Active'),
        ('suspended', 'Suspended'),
    )

    full_name = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    profile_picture = models.URLField(blank=True, null=True)
    join_date = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    completion_rate = models.FloatField(default=0.0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.full_name

class Habit(models.Model):
    HABIT_TYPE_CHOICES = (
        ('good', 'Good'),
        ('bad', 'Bad'),
    )

    habit_name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    type = models.CharField(max_length=10, choices=HABIT_TYPE_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.habit_name

class UserHabit(models.Model):
    STATUS_CHOICES = (
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    habit = models.ForeignKey(Habit, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='in_progress')
    assigned_date = models.DateTimeField(auto_now_add=True)
    completed_date = models.DateTimeField(blank=True, null=True)

    def __str__(self):
        return f"{self.user.full_name} - {self.habit.habit_name}"

class Task(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    habit = models.ForeignKey(Habit, on_delete=models.CASCADE)
    task_name = models.CharField(max_length=255)
    is_completed = models.BooleanField(default=False)
    created_date = models.DateTimeField(auto_now_add=True)
    completed_date = models.DateTimeField(blank=True, null=True)

    def __str__(self):
        return self.task_name

class DeviceUsage(models.Model):
    DEVICE_CHOICES = (
        ('mobile', 'Mobile'),
        ('tablet', 'Tablet'),
        ('unknown', 'Unknown'),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    device_type = models.CharField(max_length=20, choices=DEVICE_CHOICES)
    usage_count = models.PositiveIntegerField(default=0)
    recorded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.full_name} - {self.device_type}"

class ScreenTime(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateField()
    active_minutes = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"{self.user.full_name} - {self.date}"

class UserAnalytics(models.Model):
    ENGAGEMENT_CHOICES = (
        ('high', 'Highly Engaged'),
        ('moderate', 'Moderately Engaged'),
        ('low', 'Low Engagement'),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    engagement_level = models.CharField(max_length=20, choices=ENGAGEMENT_CHOICES)
    last_active_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.full_name} - {self.engagement_level}"

class HabitAnalytics(models.Model):
    date = models.DateField()
    habits_created = models.PositiveIntegerField(default=0)
    habits_completed = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"{self.date} - Created: {self.habits_created}, Completed: {self.habits_completed}"

class Blog(models.Model):
    title = models.CharField(max_length=255)
    content = models.TextField()
    attachment_url = models.URLField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    due_date = models.DateField(blank=True, null=True)

    def __str__(self):
        return self.title

class UserBlogView(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE)
    viewed_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.full_name} viewed {self.blog.title}"


class AdminAction(models.Model):
    ACTION_CHOICES = (
        ('suspend', 'Suspend User'),
        ('email_sent', 'Email Sent'),
    )

    admin_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='admin_actions')
    action_type = models.CharField(max_length=20, choices=ACTION_CHOICES)
    target_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='targeted_actions')
    action_date = models.DateTimeField(auto_now_add=True)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.admin_user.full_name} {self.action_type} {self.target_user.full_name}"

