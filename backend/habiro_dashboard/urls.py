from django.urls import path
from . import views
from django.conf import settings
from django.conf.urls.static import static
from .views import dashboard_overview
urlpatterns = [
    path('dashboard-overview/', dashboard_overview, name='dashboard-overview'),
]
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)