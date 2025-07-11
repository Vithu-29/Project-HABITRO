from django.urls import path
from .views import (
    RegisterView, VerifyOTPView, LoginView,
    ForgotPasswordView, VerifyForgotPasswordOTPView,
    ResetPasswordView, TestSMSView, ResendOTPView, social_login, ChallengeListView,UserChallengeListView,JoinChallengeView,UpdateChallengeHabitView
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    path('login/', LoginView.as_view(), name='login'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('verify-forgot-password-otp/', VerifyForgotPasswordOTPView.as_view(),name='verify-forgot-password-otp'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
    path('social-login/', social_login, name='social-login'),
    path('test-sms/', TestSMSView.as_view(), name='test-sms'),
    path('resend-otp/', ResendOTPView.as_view(), name='resend-otp'),
    path('challenges/', ChallengeListView.as_view(), name='challenge-list'),
    path('user-challenges/', UserChallengeListView.as_view(), name='user-challenge-list'),
    path('join-challenge/', JoinChallengeView.as_view(), name='join-challenge'),
    path('update-habit/<int:habit_id>/', UpdateChallengeHabitView.as_view(), name='update-habit'),
    
]
