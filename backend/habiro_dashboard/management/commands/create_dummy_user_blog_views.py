
from django.core.management.base import BaseCommand
from habiro_dashboard.models import create_user, Blog, UserBlogView
import random

class Command(BaseCommand):
    help = 'Create dummy user blog views'

    def handle(self, *args, **kwargs):
        users = create_user.objects.all()
        blogs = Blog.objects.all()

        for user in users:
            viewed_blogs = random.sample(list(blogs), k=3)  # user viewed 3 blogs
            for blog in viewed_blogs:
                UserBlogView.objects.create(
                    user=user,
                    blog=blog,
                )
        
        self.stdout.write(self.style.SUCCESS('Successfully created user blog views.'))
