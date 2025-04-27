from django.core.management.base import BaseCommand
from habiro_dashboard.models import User, Habit, UserHabit
import random

class Command(BaseCommand):
    help = 'Create dummy user habits'

    def handle(self, *args, **kwargs):
        users = User.objects.all()
        habits = Habit.objects.all()

        for user in users:
            assigned_habits = random.sample(list(habits), k=3)  # each user gets 3 habits
            for habit in assigned_habits:
                UserHabit.objects.create(
                    user=user,
                    habit=habit,
                    status=random.choice(['in_progress', 'completed']),
                )
        
        self.stdout.write(self.style.SUCCESS('Successfully assigned habits to users.'))
