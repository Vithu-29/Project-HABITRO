from django.shortcuts import render
from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.utils import timezone
from datetime import timedelta
from .models import User, Task, ScreenTime

def hello_world(request):
    return JsonResponse({'message': 'Hello, World!'})



@api_view(['GET'])
def dashboard_overview(request):
    today = timezone.now().date()
    yesterday = today - timedelta(days=1)

    # Total Users
    total_users_today = User.objects.filter(created_at__date=today).count()
    total_users_yesterday = User.objects.filter(created_at__date=yesterday).count()
    total_users_all = User.objects.count()
    user_growth_rate = calculate_growth_rate(total_users_today, total_users_yesterday)

    # Average Active Time Today
    screen_times_today = ScreenTime.objects.filter(date=today)
    total_active_minutes = sum([st.active_minutes for st in screen_times_today])
    user_count_today = screen_times_today.count()
    average_active_minutes = total_active_minutes / user_count_today if user_count_today else 0

    # Total Tasks
    total_tasks = Task.objects.count()

    # Active Users (today's active users)
    active_users_today = User.objects.filter(is_active=True, join_date__date=today).count()
    active_users_yesterday = User.objects.filter(is_active=True, join_date__date=yesterday).count()
    active_user_growth = calculate_growth_rate(active_users_today, active_users_yesterday)

    return Response({
        "views": {
            "value": total_users_all,
            "growthRate": round(user_growth_rate, 2),
        },
        "profit": {
            "value": round(average_active_minutes, 2),
            "growthRate": 0,  # you can calculate if needed
        },
        "products": {
            "value": total_tasks,
            "growthRate": 0,  # calculate if you want
        },
        "users": {
            "value": active_users_today,
            "growthRate": round(active_user_growth, 2),
        },
    })

def calculate_growth_rate(today_count, yesterday_count):
    if yesterday_count == 0:
        return today_count * 100  # handle divide-by-zero case
    return ((today_count - yesterday_count) / yesterday_count) * 100


