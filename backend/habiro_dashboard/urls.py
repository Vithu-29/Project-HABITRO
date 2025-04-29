from django.urls import path
from . import views
from django.conf import settings
from django.conf.urls.static import static
from .views import (
    dashboard_overview,
    active_users_chart,
    used_devices_data,
    recent_users,
    user_management_list,
    send_email_to_user,
    suspend_user
)

urlpatterns = [
    path('dashboard-overview/', dashboard_overview, name='dashboard-overview'),
    path('active-users-chart/', active_users_chart, name='active-users-chart'), 
    path('used-devices-data/', used_devices_data, name='used-devices-data'),
    path('recent-users/', recent_users, name='recent-users'),
    path('user-management/', user_management_list, name='user-management'),
    path('send-email/', send_email_to_user),  
    path('suspend-user/', suspend_user),
]
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)