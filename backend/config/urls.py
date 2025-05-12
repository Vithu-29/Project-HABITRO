from django.contrib import admin
from django.urls import path, include
from .views import root_view

urlpatterns = [
    path('admin/', admin.site.urls),  # Django admin interface
    
    # API endpoints
    path('admin_auth/', include('admin_auth.urls')), 
    
    # Frontend app (if needed)
    path('app_frontend/', include('app_frontend.urls')),
    
    # Root endpoint
    path('', root_view, name='root'),
]

handler404 = 'config.views.handler404'
handler500 = 'config.views.handler500'