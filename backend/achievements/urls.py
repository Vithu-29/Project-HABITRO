from django.urls import path
from .views import AllAchievementsView, ClaimAchievementView, UnlockedAchievementsView

urlpatterns = [
    path('all/', AllAchievementsView.as_view(), name='all_achievements'),
    path('unlocked/', UnlockedAchievementsView.as_view(), name='unlocked_achievements'),
    path('claim/<int:achievement_id>/', ClaimAchievementView.as_view(), name='claim_achievement'),
]
