from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import GameStats
from rewards.models import Reward
from .serializers import GameStartSerializer, GameResultSerializer

class GameStartView(APIView):
    def post(self, request):
        serializer = GameStartSerializer(data=request.data)
        if serializer.is_valid():
            # Deduct gems
            reward = Reward.objects.get(user_id=1)
            reward.gems -= 2
            reward.save()
            return Response({'success': True, 'remaining_gems': float(reward.gems)})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class GameResultView(APIView):
    def post(self, request):
        serializer = GameResultSerializer(data=request.data)
        if serializer.is_valid():
            time_taken = serializer.validated_data['time_taken']
            won = serializer.validated_data['won']
            
            # Update rewards if won
            reward = Reward.objects.get(user_id=1)
            if won:
                reward.gems += 4
                reward.save()
            
            # Update game stats
            stats, created = GameStats.objects.get_or_create(user_id=1)
            if won:
                stats.games_won += 1
                if time_taken < stats.best_time or stats.best_time == 0:
                    stats.best_time = time_taken
                stats.save()
            
            return Response({
                'gems': float(reward.gems),
                'games_won': stats.games_won,
                'best_time': stats.best_time
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class GameStatsView(APIView):
    def get(self, request):
        stats, _ = GameStats.objects.get_or_create(user_id=1)
        return Response({
            'best_time': stats.best_time,
            'games_won': stats.games_won
        })  