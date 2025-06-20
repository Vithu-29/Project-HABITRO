from rest_framework import serializers
from rewards.models import Reward

class GameStartSerializer(serializers.Serializer):
    def validate(self, attrs):
        user = self.context['request'].user
        try:
            reward = Reward.objects.get(user=user)
            if reward.gems < 2:
                raise serializers.ValidationError("Not enough gems to play")
            return attrs
        except Reward.DoesNotExist:
            raise serializers.ValidationError("User reward not found")

class GameResultSerializer(serializers.Serializer):
    time_taken = serializers.IntegerField()
    won = serializers.BooleanField()