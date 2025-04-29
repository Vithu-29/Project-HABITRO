# habiro_dashboard/management/commands/seed_all_dummy_data.py

from django.core.management.base import BaseCommand
from django.core import management

class Command(BaseCommand):
    help = 'Seed dummy data for all tables at once.'

    def handle(self, *args, **kwargs):
        commands = [
            'create_dummy_users',
            'create_dummy_habits',
            'create_dummy_userhabits',
            'create_dummy_tasks',
            'create_dummy_device_usages',
            'create_dummy_screen_times',
            'create_dummy_user_analytics',
            'create_dummy_habit_analytics',
            'create_dummy_blogs',
            'create_dummy_user_blog_views',
            'create_dummy_admin_actions',
        ]

        for command in commands:
            self.stdout.write(self.style.WARNING(f'Running {command}...'))
            management.call_command(command)

        self.stdout.write(self.style.SUCCESS('✅ Successfully seeded all dummy data!'))
