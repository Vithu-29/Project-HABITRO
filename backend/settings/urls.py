from django.urls import path
from .views import FontSizePreferenceView

urlpatterns = [
    path('font-size/', FontSizePreferenceView.as_view(), name='font-size'),
]