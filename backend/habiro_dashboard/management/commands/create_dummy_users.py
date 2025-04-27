from django.core.management.base import BaseCommand
from habiro_dashboard.models import User  # change 'habiro_dashboard' to your app name
import random
from faker import Faker
from datetime import timedelta
from django.utils import timezone

fake = Faker()

class Command(BaseCommand):
    help = 'Create dummy users'

    def handle(self, *args, **kwargs):
        profile_pic_url = '/media/profile_images/default.jpg'

        statuses = ['active', 'suspended']

        for _ in range(20):
            full_name = fake.name()
            email = fake.unique.email()
            join_date = timezone.now() - timedelta(days=random.randint(1, 365))
            completion_rate = round(random.uniform(10.0, 100.0), 2)
            status = random.choice(statuses)
            is_active = True if status == 'active' else False

            User.objects.create(
                full_name=full_name,
                email=email,
                profile_picture=profile_pic_url,
                join_date=join_date,
                completion_rate=completion_rate,
                status=status,
                is_active=is_active,
            )

        self.stdout.write(self.style.SUCCESS('Successfully created 20 dummy users.'))
