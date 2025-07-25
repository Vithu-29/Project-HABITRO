from django.db import models
from decimal import Decimal
from django.contrib.auth import get_user_model

class Reward(models.Model):
    user = models.OneToOneField(  # 🔁 changed from ForeignKey
        get_user_model(),
        on_delete=models.CASCADE,
        related_name='reward',  # singular form
        null=False,  # Better to enforce this as required
        unique=True  # Just to be safe, though OneToOneField implies it
    )
    coins = models.IntegerField(default=100)
    gems = models.DecimalField(max_digits=5, decimal_places=1, default=Decimal('2.0'))
    daily_streak = models.IntegerField(default=0)
    max_streak = models.IntegerField(default=0)
    last_claim_date = models.DateTimeField(null=True, blank=True)
    streak_cycle_day = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user_id}'s Rewards"
