from django.apps import apps
from .models import UserProfile

def create_profiles_for_existing_users():
    UserModel = apps.get_model('app_frontend', 'CustomUser')
    for user in UserModel.objects.all():
        if not hasattr(user, 'profile'):
            UserProfile.objects.create(
                user=user,
                full_name=user.full_name,
                email=user.email,
                phone_number=user.phone_number
            )
