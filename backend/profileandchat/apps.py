from django.apps import AppConfig

class ProfileandchatConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'profileandchat'

    def ready(self):
        import profileandchat.signals
