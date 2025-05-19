from django.db import models
from decimal import Decimal

class Reward(models.Model):
    user_id = models.IntegerField(default=1)
    coins = models.IntegerField(default=100)
    gems = models.DecimalField(max_digits=5, decimal_places=1, default=Decimal('0.0'))
    daily_streak = models.IntegerField(default=0)
    max_streak = models.IntegerField(default=0)
    last_claim_date = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.user_id}'s Rewards"