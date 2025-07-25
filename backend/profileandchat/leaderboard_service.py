# services/leaderboard_service.py

from django.db.models import Count, Q, F, ExpressionWrapper, FloatField
from django.db.models.functions import Coalesce, NullIf
from django.utils import timezone
from datetime import timedelta
from analyze_responses.models import Task, Habit
from django.contrib.auth import get_user_model

User = get_user_model()

def calculate_completion_rate(period):
    today = timezone.now().date()

    if period == 'weekly':
        start_date = today - timedelta(days=today.weekday())  # Monday
    elif period == 'monthly':
        start_date = today.replace(day=1)
    else:  # all_time
        start_date = None

    users = User.objects.annotate(
        total_tasks=Count(
            'habits__tasks',
            filter=Q(habits__tasks__date__lte=today) &
                   (Q(habits__tasks__date__gte=start_date) if start_date else Q())
        ),
        completed_tasks=Count(
            'habits__tasks',
            filter=Q(habits__tasks__isCompleted=True) &
                   Q(habits__tasks__date__lte=today) &
                   (Q(habits__tasks__date__gte=start_date) if start_date else Q())
        )
    ).annotate(
        completion_rate=Coalesce(
            ExpressionWrapper(
                100.0 * F('completed_tasks') / NullIf(F('total_tasks'), 0),
                output_field=FloatField()
            ),
            0.0,
            output_field=FloatField()
        )
    ).order_by('-completion_rate', '-completed_tasks', 'date_joined')

    return users
