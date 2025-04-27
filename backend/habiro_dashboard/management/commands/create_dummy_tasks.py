from django.core.management.base import BaseCommand
from habiro_dashboard.models import User, Habit, Task
import random
from faker import Faker

fake = Faker()

class Command(BaseCommand):
    help = 'Create dummy tasks'

    def handle(self, *args, **kwargs):
        users = User.objects.all()
        habits = Habit.objects.all()

        for user in users:
            for _ in range(5):  # 5 tasks per user
                habit = random.choice(habits)
                Task.objects.create(
                    user=user,
                    habit=habit,
                    task_name=fake.sentence(nb_words=3),
                    is_completed=random.choice([True, False]),
                )

        self.stdout.write(self.style.SUCCESS('Successfully created tasks for users.'))
