# Generated by Django 5.2 on 2025-05-20 12:20

from decimal import Decimal
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('rewards', '0002_remove_reward_user_id_reward_user'),
    ]

    operations = [
        migrations.AlterField(
            model_name='reward',
            name='gems',
            field=models.DecimalField(decimal_places=1, default=Decimal('2.0'), max_digits=5),
        ),
    ]
