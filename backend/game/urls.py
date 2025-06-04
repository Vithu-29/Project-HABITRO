from django.urls import path
from .views import GameStartView, GameResultView, GameStatsView

urlpatterns = [
    path('start/', GameStartView.as_view(), name='game-start'),
    path('result/', GameResultView.as_view(), name='game-result'),
    path('stats/', GameStatsView.as_view(), name='game-stats'),
]