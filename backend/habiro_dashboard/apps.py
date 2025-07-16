from django.apps import AppConfig


class CoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'habiro-dashboard'


class HabiroDashboardConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'habiro_dashboard'

