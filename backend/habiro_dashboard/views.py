from django.shortcuts import render
from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.utils import timezone
from datetime import timedelta
from .models import User, Task, ScreenTime

def hello_world(request):
    return JsonResponse({'message': 'Hello, World!'})
 ## Dashboard Overview-card
def calculate_growth_rate(today_count, yesterday_count):
    if yesterday_count == 0:
        return today_count * 100
    return ((today_count - yesterday_count) / yesterday_count) * 100

@api_view(['GET'])
def dashboard_overview(request):
    today = timezone.now().date()
    yesterday = today - timedelta(days=1)

    # Total Users
    total_users_all = User.objects.count()
    new_users_today = User.objects.filter(created_at__date=today).count()
    new_users_yesterday = User.objects.filter(created_at__date=yesterday).count()
    user_growth_rate = calculate_growth_rate(new_users_today, new_users_yesterday)

    # Active Users Today
    active_users_today = ScreenTime.objects.filter(date=today).count()
    active_users_yesterday = ScreenTime.objects.filter(date=yesterday).count()
    active_user_growth = calculate_growth_rate(active_users_today, active_users_yesterday)

    # Average Active Time Today
    screen_times_today = ScreenTime.objects.filter(date=today)
    total_active_minutes = sum(st.active_minutes for st in screen_times_today)
    user_count_today = screen_times_today.count()
    average_active_minutes = total_active_minutes / user_count_today if user_count_today else 0

    # Total Tasks
    total_tasks = Task.objects.count()

    return Response({
        "views": {
            "value": total_users_all,
            "growthRate": round(user_growth_rate, 2),
        },
        "profit": {
            "value": round(average_active_minutes, 2),
            "growthRate": 0,
        },
        "products": {
            "value": total_tasks,
            "growthRate": 0,
        },
        "users": {
            "value": active_users_today,
            "growthRate": round(active_user_growth, 2),
        },
    })
  #active users chart
@api_view(['GET'])
def active_users_chart(request):
    today = timezone.now().date()

    chart_data = []
    total_visitors = 0

    for i in range(6, -1, -1):  # 6 days ago to today
        date = today - timedelta(days=i)
        active_users = ScreenTime.objects.filter(date=date).count()
        total_visitors += active_users
        day_name = date.strftime('%a')[0]  
        chart_data.append({
            "x": day_name,
            "y": active_users,
        })

    today_active = ScreenTime.objects.filter(date=today).count()
    yesterday_active = ScreenTime.objects.filter(date=today - timedelta(days=1)).count()

    if yesterday_active == 0:
        performance = today_active * 100
    else:
        performance = ((today_active - yesterday_active) / yesterday_active) * 100

    return Response({
        "total_visitors": total_visitors,
        "performance": round(performance, 2),
        "chart": chart_data,
    })
    
    
  #Used Devices Chart
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import DeviceUsage
from django.db.models import Sum

@api_view(['GET'])
def used_devices_data(request):
    device_types = ['mobile', 'tablet', 'unknown']

    device_data = []

    for device_type in device_types:
        count = DeviceUsage.objects.filter(device_type=device_type).aggregate(
            total_usage=Sum('usage_count')
        )['total_usage'] or 0

        device_data.append({
            "name": device_type.capitalize(),  # Capitalize name: Mobile, Tablet, Unknown
            "amount": count,
        })

    return Response(device_data)

#Recent Users

# habiro_dashboard/views.py

from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.utils import timezone
from django.conf import settings
from .models import User, UserHabit, Habit

@api_view(['GET'])
def recent_users(request):
    users = User.objects.order_by('-join_date')[:6]  # Last 6 users joined

    data = []

    for user in users:
        # Get the first habit the user is trying to overcome (good habit)
        user_habit = UserHabit.objects.filter(user=user, status='in_progress').first()
        added_habit_name = user_habit.habit.habit_name if user_habit else 'No Habit Added'

        # Handling profile picture full URL
        if user.profile_picture:
            if user.profile_picture.startswith("/media/"):
                avatar_url = request.build_absolute_uri(user.profile_picture)
            else:
                avatar_url = user.profile_picture
        else:
            avatar_url = f"https://api.dicebear.com/7.x/initials/svg?seed={user.full_name.replace(' ', '+')}"

        data.append({
            "name": user.full_name,
            "email": user.email,
            "joined": user.join_date.strftime("%Y-%m-%d %I:%M %p"),
            "habit": added_habit_name,
            "avatar": avatar_url,
        })

    return Response(data)

# user_management_list

from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.utils import timezone
from django.db.models import Count, Q
from .models import User, UserHabit, Habit, ScreenTime, Task

@api_view(['GET'])
def user_management_list(request):
    users = User.objects.all().order_by('-join_date')  

    data = []

    for user in users:
        # Profile picture
        if user.profile_picture:
            if user.profile_picture.startswith("/media/"):
                avatar_url = request.build_absolute_uri(user.profile_picture)
            else:
                avatar_url = user.profile_picture
        else:
            avatar_url = f"https://api.dicebear.com/7.x/initials/svg?seed={user.full_name.replace(' ', '+')}"

        # Good and Bad Habits
        user_habits = UserHabit.objects.filter(user=user).select_related('habit')

        good_habits = [uh.habit.habit_name for uh in user_habits if uh.habit.type == 'good']
        bad_habits = [uh.habit.habit_name for uh in user_habits if uh.habit.type == 'bad']

        # Screen Time (Last 7 days)
        today = timezone.now().date()
        last_week_dates = [today - timezone.timedelta(days=i) for i in range(6, -1, -1)]
        screen_times = []
        for date in last_week_dates:
            st = ScreenTime.objects.filter(user=user, date=date).first()
            screen_times.append(round(st.active_minutes / 60, 1) if st else 0)  # convert minutes to hours

        # Task Completion
        completed_tasks = Task.objects.filter(user=user, is_completed=True).count()
        pending_tasks = Task.objects.filter(user=user, is_completed=False).count()

        data.append({
            "id": user.id,
            "name": user.full_name,
            "email": user.email,
            "joined": user.join_date.strftime("%d %b, %Y"),
            "completionRate": f"{user.completion_rate}%",
            "profilePicture": avatar_url,
            "isActive": user.status == "active",
            "goodHabits": good_habits,
            "badHabits": bad_habits,
            "screenTime": screen_times,
            "tasks": {
                "completed": completed_tasks,
                "pending": pending_tasks,
            }
        })

    return Response(data)

from django.core.mail import send_mail
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
# send_email_to_user
@api_view(['POST'])
def send_email_to_user(request):
    """
    API to send an email to a user.
    POST body should contain: { "email": "user@example.com", "subject": "Your Subject", "message": "Your message" }
    """
    try:
        email = request.data.get('email')
        subject = request.data.get('subject')
        message = request.data.get('message')

        if not all([email, subject, message]):
            return Response({'error': 'Missing email, subject, or message.'}, status=status.HTTP_400_BAD_REQUEST)

        send_mail(
            subject,
            message,
            'thajeevanv.22@uom.lk',  # Replace with your backend email address (Django settings)
            [email],
            fail_silently=False,
        )
        return Response({'message': 'Email sent successfully!'})
    
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
# suspend_user
@api_view(['POST'])
def suspend_user(request):
    """
    API to suspend a user.
    POST body should contain: { "user_id": 123 }
    """
    try:
        user_id = request.data.get('user_id')
        if not user_id:
            return Response({'error': 'User ID not provided'}, status=400)

        user = User.objects.get(id=user_id)
        user.status = 'suspended'
        user.is_active = False
        user.save()

        return Response({'message': 'User suspended successfully'})
    
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=500)


# analysis page
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.utils import timezone
from .models import ScreenTime
from django.db.models import Sum
from datetime import timedelta

@api_view(['GET'])
def app_usage_data(request):
    today = timezone.now().date()
    past_5_days = [today - timedelta(days=i) for i in range(4, -1, -1)]
    
    data = []
    for date in past_5_days:
        total_minutes = ScreenTime.objects.filter(date=date).aggregate(Sum('active_minutes'))['active_minutes__sum'] or 0
        data.append({
            "date": date.strftime("%a"),  # "Mon", "Tue", ...
            "usage": total_minutes
        })

    return Response(data)

@api_view(['GET'])
def habit_trends(request):
    from django.db.models import Count
    from .models import Habit, UserHabit

    bad_habits = Habit.objects.filter(type="bad")
    data = []

    for habit in bad_habits:
        count = UserHabit.objects.filter(habit=habit).count()
        data.append({
            "habit": habit.habit_name,
            "users": count
        })

    return Response(data)
@api_view(['GET'])
def user_engagement_data(request):
    from .models import UserAnalytics

    data = UserAnalytics.objects.values('engagement_level').annotate(count=Count('id'))

    result = []
    for row in data:
        label = row['engagement_level'].replace("_", " ").title()
        result.append({
            "name": label,
            "value": row['count']
        })

    return Response(result)
