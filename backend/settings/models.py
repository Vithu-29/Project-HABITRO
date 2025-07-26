from django.db import models
from django.conf import settings

class UserAppearanceSetting(models.Model):
    FONT_SIZE_CHOICES = [
        ('small', 'Small'),
        ('normal', 'Normal'),
        ('large', 'Large'),
    ]
    
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    font_size = models.CharField(max_length=10, choices=FONT_SIZE_CHOICES, default='normal')

    def __str__(self):
        return f"{self.user.username}'s appearance settings"
