from django.contrib import admin
from .models import Task,Habit

class HabitAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'type', 'created_at')  # Show in list view
    readonly_fields = ('id',)  # Show in detail view (non-editable)

admin.site.register(Task)
admin.site.register(Habit, HabitAdmin)
