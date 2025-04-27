from django.core.management.base import BaseCommand
from habiro_dashboard.models import User, AdminAction
import random

class Command(BaseCommand):
    help = 'Create dummy admin actions'

    def handle(self, *args, **kwargs):
        admins = User.objects.filter(is_active=True)[:5]  # assume first 5 users are admins
        targets = User.objects.filter(is_active=False)

        for admin in admins:
            if targets.exists():
                target = random.choice(targets)
                AdminAction.objects.create(
                    admin_user=admin,
                    action_type=random.choice(['suspend', 'email_sent']),
                    target_user=target,
                    description='Dummy admin action performed.',
                )

        self.stdout.write(self.style.SUCCESS('Successfully created admin actions.'))
