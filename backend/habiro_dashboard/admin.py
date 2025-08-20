from django.contrib import admin
from .models import create_user, DeviceUsage

admin.site.register(create_user)
admin.site.register(DeviceUsage)

# Register your models here.
