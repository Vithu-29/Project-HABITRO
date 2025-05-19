from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),  # Django admin interface
    
    # API endpoints
    path('admin_auth/', include('admin_auth.urls')), 
    
    # Frontend app (if needed)
    path('app_frontend/', include('app_frontend.urls')),
    
    
]
