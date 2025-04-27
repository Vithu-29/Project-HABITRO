from django.core.management.base import BaseCommand
from habiro_dashboard.models import HabitAnalytics
from datetime import timedelta
from django.utils import timezone
import random

class Command(BaseCommand):
    help = 'Create dummy habit analytics'

    def handle(self, *args, **kwargs):
        for i in range(7):  # Last 7 days
            date = timezone.now().date() - timedelta(days=i)
            HabitAnalytics.objects.create(
                date=date,
                habits_created=random.randint(5, 20),
                habits_completed=random.randint(5, 20),
            )

        self.stdout.write(self.style.SUCCESS('Successfully created habit analytics records.'))
