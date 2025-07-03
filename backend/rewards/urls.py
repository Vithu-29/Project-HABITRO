from django.urls import path
from . import views

urlpatterns = [
    path('rewards/', views.get_rewards),
    path('convert/', views.convert_coins),
    path('claim-streak/', views.claim_streak),
]