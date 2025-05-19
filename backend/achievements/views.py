from decimal import Decimal
from rest_framework.views import APIView
from rest_framework.response import Response

from rewards.models import Reward
from .models import Achievement , UserAchievement
from .serializers import AchievementSerializer , UserAchievementSerializer

class AllAchievementsView(APIView):
    def get(self, request):
        user_id = 1  # Replace with authenticated user later
        global_achievements = Achievement.objects.all()
        user_achievements = UserAchievement.objects.filter(user_id=user_id)
        
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
    def get(self, request):
        unlocked = UserAchievement.objects.filter(user_id=1, unlocked=True)[:8]
        serializer = UserAchievementSerializer(unlocked, many=True)
        return Response(serializer.data)

class ClaimAchievementView(APIView):
    def post(self, request, achievement_id):
        user_id = 1  # Replace with request.user.id after auth
        try:
            user_achievement = UserAchievement.objects.get(
                user_id=user_id,
                achievement_id=achievement_id,
                unlocked=True,
                is_collected=False
            )
            user_achievement.is_collected = True
            user_achievement.save()
            
            # Grant rewards (same as before)
            reward = Reward.objects.get(user_id=user_id)
            reward.coins += 500
            reward.gems += Decimal('1.0')
            reward.save()
            
            return Response(status=200)
        except UserAchievement.DoesNotExist:
            return Response({"error": "Invalid claim"}, status=400)