from django.urls import path
from .views import AdminRegisterView

urlpatterns = [
    path('admin-register/', AdminRegisterView.as_view(), name='admin-register'),
]