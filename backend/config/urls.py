from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),  # Django admin interface
    
    # API endpoints
    path('admin_auth/', include('admin_auth.urls')), 
    
    path('api/', include('deepapi.urls')),
    path('api/', include('analyze_responses.urls')),
    # Frontend app (if needed)
    path('app_frontend/', include('app_frontend.urls')),
    path('api/', include('app_frontend.urls')),
    
    
    path('quiz/', include('quiz.urls')),
    path('api/', include('rewards.urls')),
    path('game/', include('game.urls')),
    path('achievements/', include('achievements.urls')),
    path('article/', include('articles.urls')),
    path('profile/', include('profileandchat.urls')),
    path('api/settings/', include('settings.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
