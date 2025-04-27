from django.core.management.base import BaseCommand
from habiro_dashboard.models import User, ScreenTime
import random
from datetime import timedelta
from django.utils import timezone

class Command(BaseCommand):
    help = 'Create dummy screen times'

    def handle(self, *args, **kwargs):
        users = User.objects.all()

        for user in users:
            for i in range(7):  # Last 7 days
                date = timezone.now().date() - timedelta(days=i)
                ScreenTime.objects.create(
                    user=user,
                    date=date,
                    active_minutes=random.randint(30, 300),
                )

        self.stdout.write(self.style.SUCCESS('Successfully created screen times for users.'))
