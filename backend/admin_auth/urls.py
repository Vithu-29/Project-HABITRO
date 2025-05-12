from django.urls import path
from .views import AdminLoginView

urlpatterns = [
    path('admin-login/', AdminLoginView.as_view(), name='admin-login'),
]