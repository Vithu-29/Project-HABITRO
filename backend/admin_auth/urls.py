from django.urls import path
from .views import (
    AdminLoginView,
    ForgotPasswordView,
    VerifyOTPView,
    ResetPasswordView
)

urlpatterns = [
    path('admin-login/', AdminLoginView.as_view(), name='admin-login'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
]

