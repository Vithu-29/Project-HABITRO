from decimal import Decimal
from rest_framework.views import APIView
from rest_framework.response import Response

from rewards.models import Reward
from .models import Achievement , UserAchievement
from .serializers import AchievementSerializer , UserAchievementSerializer
from rest_framework.permissions import IsAuthenticated

class AllAchievementsView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        user= request.user
        global_achievements = Achievement.objects.all()
        user_achievements = UserAchievement.objects.filter(user=user)
        
        merged_data = []
        for achievement in global_achievements:
            user_data = user_achievements.filter(achievement=achievement).first()
            merged_data.append({
                "id": achievement.id,
                "title": achievement.title,
                "description": achievement.description,
                "image": achievement.image.url if achievement.image else "",
                "unlocked": user_data.unlocked if user_data else False,
                "is_collected": user_data.is_collected if user_data else False,
            })
        return Response(merged_data)

class UnlockedAchievementsView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        unlocked = UserAchievement.objects.filter(user=request.user, unlocked=True)[:8]
        serializer = UserAchievementSerializer(unlocked, many=True)
        return Response(serializer.data)

class ClaimAchievementView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, achievement_id):
        user = request.user 
        try:
            user_achievement = UserAchievement.objects.get(
                user=user,
                achievement_id=achievement_id,
                unlocked=True,
                is_collected=False
            )
            user_achievement.is_collected = True
            user_achievement.save()
            
            reward = Reward.objects.get(user=user)
            reward.coins += 500
            reward.gems += Decimal('1.0')
            reward.save()
            
            return Response(status=200)
        except UserAchievement.DoesNotExist:
            return Response({"error": "Invalid claim"}, status=400)