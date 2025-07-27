from django.urls import path
from .views import (
    AdminLoginView,
    ForgotPasswordView,
    VerifyOTPView,
    ResetPasswordView,
    change_password
)

urlpatterns = [
    path('admin-login/', AdminLoginView.as_view(), name='admin-login'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
    path('change-password/', change_password, name='change-password'),  # ✅ Correct path
]
