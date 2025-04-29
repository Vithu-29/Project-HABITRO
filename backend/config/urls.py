from django.contrib import admin
from django.urls import path ,include
from habiro_dashboard import views
from django.conf import settings
from django.conf.urls.static import static
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('habiro_dashboard.urls')),
    path('api/user-management/', views.user_management_list, name='user-management'),
   

]
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)