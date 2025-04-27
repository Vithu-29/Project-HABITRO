from django.core.management.base import BaseCommand
from habiro_dashboard.models import User, DeviceUsage
import random

class Command(BaseCommand):
    help = 'Create dummy device usages'

    def handle(self, *args, **kwargs):
        device_types = ['mobile', 'tablet', 'unknown']
        users = User.objects.all()

        for user in users:
            DeviceUsage.objects.create(
                user=user,
                device_type=random.choice(device_types),
                usage_count=random.randint(1, 50),
            )
        
        self.stdout.write(self.style.SUCCESS('Successfully created device usage records.'))
