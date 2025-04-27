from django.core.management.base import BaseCommand
from habiro_dashboard.models import Habit
from faker import Faker
import random

fake = Faker()

class Command(BaseCommand):
    help = 'Create dummy habits'

    def handle(self, *args, **kwargs):
        habit_types = ['good', 'bad']

        for _ in range(20):
            Habit.objects.create(
                habit_name=fake.word().capitalize() + " Habit",
                description=fake.sentence(),
                type=random.choice(habit_types),
            )
        
        self.stdout.write(self.style.SUCCESS('Successfully created 20 dummy habits.'))
