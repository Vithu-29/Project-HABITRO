from django.apps import AppConfig


class AchievementConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'achievements'
    
    def ready(self):
        from . import signals