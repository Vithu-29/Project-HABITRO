from django.urls import path, include
from . import views
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from .views import (
    dashboard_overview,
    active_users_chart,
    used_devices_data,
    recent_users,
    user_management_list,
    send_email_to_user,
    suspend_user,
    create_article,
    ArticleListCreateView
    
)
router = DefaultRouter()
urlpatterns = [
    path('dashboard-overview/', dashboard_overview, name='dashboard-overview'),
    path('active-users-chart/', active_users_chart, name='active-users-chart'), 
    path('used-devices-data/', used_devices_data, name='used-devices-data'),
    path('recent-users/', recent_users, name='recent-users'),
    path('user-management/', user_management_list, name='user-management'),
    path('send-email/', send_email_to_user),  
    path('suspend-user/', suspend_user),
    path("analytics/app-usage/", views.app_usage_data),
    path("analytics/habit-trends/", views.habit_trends),
    path("analytics/user-engagement/", views.user_engagement_data),
    path('habit-overview/', views.habit_overview_chart),
    path('habit-type-overview/', views.habit_type_overview),
    path('good-habit-analytics/', views.good_habit_analytics),
    path('good-habit-analytics/<int:habit_id>/users/', views.habit_completed_users),
    path('create-article/', create_article, name='create-article'),
    path('articles/', ArticleListCreateView.as_view(), name='article-list-create'),

    path('api/', include(router.urls)),
    
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
