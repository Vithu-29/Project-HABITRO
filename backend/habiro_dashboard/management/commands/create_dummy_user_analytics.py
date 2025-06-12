from django.core.management.base import BaseCommand
from habiro_dashboard.models import create_user, UserAnalytics
import random
from datetime import timedelta
from django.utils import timezone

class Command(BaseCommand):
    help = 'Create dummy user analytics'

    def handle(self, *args, **kwargs):
        engagement_levels = ['high', 'moderate', 'low']
        users = create_user.objects.all()

        for user in users:
            UserAnalytics.objects.create(
                user=user,
                engagement_level=random.choice(engagement_levels),
                last_active_date=timezone.now().date() - timedelta(days=random.randint(0, 10)),
            )
        
        self.stdout.write(self.style.SUCCESS('Successfully created user analytics.'))
