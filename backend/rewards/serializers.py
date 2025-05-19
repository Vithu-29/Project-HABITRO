from rest_framework import serializers
from .models import Reward

class RewardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reward
        fields = ['coins', 'gems', 'daily_streak', 'max_streak', 'last_claim_date']
        read_only_fields = ['last_claim_date']