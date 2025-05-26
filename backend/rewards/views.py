from decimal import Decimal
from rest_framework.decorators import api_view,permission_classes
from rest_framework.response import Response
from rest_framework import status
from .models import Reward
from .serializers import RewardSerializer
from django.utils import timezone
from datetime import timedelta
from rest_framework.permissions import IsAuthenticated

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_rewards(request):
    reward, created = Reward.objects.get_or_create(
        user=request.user,
        defaults={
            'coins': 100,
            'gems': Decimal('2.0'),
            'daily_streak': 0,
            'max_streak': 0
        }
    )
    serializer = RewardSerializer(reward)
    return Response(serializer.data)
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def convert_coins(request):
    user=request.user
    amount = int(request.data.get('amount', 0))
    
    if amount < 100:
        return Response({"error": "Minimum 100 coins required"}, status=400)
    
    try:
        reward = Reward.objects.get(user=user)
        if reward.coins >= amount:
            reward.coins -= amount
            reward.gems += Decimal(amount) / 1000
            reward.save()
            return Response({"coins": reward.coins, "gems": reward.gems})
        return Response({"error": "Insufficient coins"}, status=400)
    except Reward.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def claim_streak(request):
    try:
        reward = Reward.objects.get(user=request.user)
        now = timezone.now()
        today = timezone.localtime(now).date()

        if reward.last_claim_date:
            last_claim_date = timezone.localtime(reward.last_claim_date).date()
            
            if last_claim_date == today:
                return Response(
                    {"error": "You've already claimed your streak today!"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Check if last claim was yesterday (consecutive)
            if (today - last_claim_date).days == 1:
                reward.daily_streak += 1
            else:
                reward.daily_streak = 1  # Reset if gap >1 day
        else:
            # First claim
            reward.daily_streak = 1

        # Update max streak and reward
        reward.max_streak = max(reward.max_streak, reward.daily_streak)
        reward.gems += Decimal('1.0')
        reward.last_claim_date = now
        reward.save()
        
        return Response(RewardSerializer(reward).data)
    except Reward.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)