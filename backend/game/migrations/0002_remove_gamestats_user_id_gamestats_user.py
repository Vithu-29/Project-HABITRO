# Generated by Django 5.2 on 2025-05-20 09:14

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('game', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.RemoveField(
            model_name='gamestats',
            name='user_id',
        ),
        migrations.AddField(
            model_name='gamestats',
            name='user',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='game_stats', to=settings.AUTH_USER_MODEL),
        ),
    ]
