from django.core.management.base import BaseCommand
from habiro_dashboard.models import Blog
from faker import Faker
import random
from datetime import timedelta
from django.utils import timezone

fake = Faker()

class Command(BaseCommand):
    help = 'Create dummy blogs'

    def handle(self, *args, **kwargs):
        for _ in range(10):
            Blog.objects.create(
                title=fake.sentence(nb_words=4),
                content=fake.text(),
                attachment_url='https://dummyurl.com/file.pdf',
                due_date=timezone.now().date() + timedelta(days=random.randint(1, 30)),
            )

        self.stdout.write(self.style.SUCCESS('Successfully created dummy blogs.'))
