from django.db import models
from decimal import Decimal
from django.contrib.auth import get_user_model

class Reward(models.Model):
    user = models.ForeignKey(
        get_user_model(),
        on_delete=models.CASCADE,
        related_name='rewards',
        null=True
    )
    coins = models.IntegerField(default=100)
    gems = models.DecimalField(max_digits=5, decimal_places=1, default=Decimal('2.0'))
    daily_streak = models.IntegerField(default=0)
    max_streak = models.IntegerField(default=0)
    last_claim_date = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.user_id}'s Rewards"