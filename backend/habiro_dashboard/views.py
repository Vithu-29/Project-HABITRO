# Importing models
from django.shortcuts import render
from django.http import JsonResponse
from django.utils import timezone
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
from rest_framework.views import APIView
from django.db.models import Sum, Count, Q
from datetime import timedelta, date
from collections import defaultdict
from django.db.models import Count, Q
from app_frontend.models import CustomUser
from analyze_responses.models import Task
from analyze_responses.models import Habit  
from articles.models import Article
from .models import (
    create_user,  ScreenTime, DeviceUsage, UserHabit,
    Habit,Task
)
from .serializers import ArticleSerializer
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
from datetime import date
from django.core.mail import send_mail
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from rest_framework import viewsets

 ## Dashboard Overview-card(Homepage)
def calculate_growth_rate(today_count, yesterday_count):
    if yesterday_count == 0:
        return today_count * 100
    return ((today_count - yesterday_count) / yesterday_count) * 100

@api_view(['GET'])
def dashboard_overview(request):
    today = timezone.now().date()
    yesterday = today - timedelta(days=1)

    # Total Users
    total_users_all = CustomUser.objects.count()
    new_users_today = CustomUser.objects.filter(date_joined__date=today).count()
    new_users_yesterday = CustomUser.objects.filter(date_joined__date=yesterday).count()
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
        "total_users": {
            "value": total_users_all,
            "growthRate": round(user_growth_rate, 2),
        },
        "active_time": {
            "value": round(average_active_minutes, 2),
            "growthRate": 0,
        },
        "total_task": {
            "value": total_tasks,
            "growthRate": 0,
        },
        "active_users": {
            "value": active_users_today,
            "growthRate": round(active_user_growth, 2),
        },
    })
  #active users chart(Homepage)
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
    
    
  #Used Devices Chart(Homepage)

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

#Recent Users(Homepage)

@api_view(['GET'])
def recent_users(request):
    users = create_user.objects.order_by('-join_date')[:6]  # Last 6 users joined

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

# user_management_list(User Management)
from django.db.models import Count, Q
from .models import create_user, UserHabit, Habit, ScreenTime

@api_view(['GET'])
def user_management_list(request):
    users = create_user.objects.all().order_by('-join_date')  

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



# send_email_to_user (User Management)
@api_view(['POST'])
def send_email_to_user(request):
    try:
        print("Received request:", request.data)  #  Add this line for debugging

        email = request.data.get('email')
        subject = request.data.get('subject')
        message = request.data.get('message')

        if not all([email, subject, message]):
            return Response({'error': 'Missing email, subject, or message.'}, status=status.HTTP_400_BAD_REQUEST)

        send_mail(
            subject,
            message,
            'ahabitro@gmail.com',  
            [email],
            fail_silently=False,
        )
        return Response({'message': 'Email sent successfully!'})

    except Exception as e:
        print("Email sending error:", str(e))  
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# suspend_user(User Management)
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

        user = create_user.objects.get(id=user_id)
        user.status = 'suspended'
        user.is_active = False
        user.save()

        return Response({'message': 'User suspended successfully'})
    
    except create_user.DoesNotExist:
        return Response({'error': 'User not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=500)


# analysis page
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

# habit_management page
from django.db.models import Count
from .models import Habit, UserHabit

from collections import defaultdict

@api_view(['GET'])
def habit_overview_chart(request):
    today = timezone.now().date()
    last_7_days = [today - timezone.timedelta(days=i) for i in range(6, -1, -1)]

    # Group by date
    created_data = defaultdict(int)
    completed_data = defaultdict(int)

    habits_created = Habit.objects.filter(created_at__date__in=last_7_days)
    for habit in habits_created:
        created_data[habit.created_at.date()] += 1

    habits_completed = UserHabit.objects.filter(completed_date__date__in=last_7_days)
    for habit in habits_completed:
        completed_data[habit.completed_date.date()] += 1

    response = {
        "habitsCreated": [{"x": str(date), "y": created_data[date]} for date in last_7_days],
        "habitsCompleted": [{"x": str(date), "y": completed_data[date]} for date in last_7_days],
    }
    return Response(response)


@api_view(['GET'])
def habit_type_overview(request):
    good_count = Habit.objects.filter(type="good").count()
    bad_count = Habit.objects.filter(type="bad").count()

    return Response({
        "goodHabits": good_count,
        "badHabits": bad_count
    })

# good_habit_analytics_table()
from .models import Habit, UserHabit

@api_view(['GET'])
def good_habit_analytics(request):
    good_habits = Habit.objects.filter(type="good")
    response = []

    for habit in good_habits:
        total_users = UserHabit.objects.filter(habit=habit).count()
        completed_users = UserHabit.objects.filter(habit=habit, status='completed').count()

        response.append({
            "habitName": habit.habit_name,
            "habitId": habit.id,
            "totalUsers": total_users,
            "completedUsers": completed_users,
        })

    return Response(response)
# view to get users who have completed a specific habit
@api_view(['GET'])
def habit_completed_users(request, habit_id):
    userhabits = UserHabit.objects.filter(habit_id=habit_id, status='completed')
    users = [{
        "id": uh.user.id,
        "name": uh.user.full_name,
        "email": uh.user.email
    } for uh in userhabits]

    return Response(users)

# dashboard/artical/views.py
class ArticleListCreateView(APIView):
    def get(self, request):
        articles = Article.objects.all().order_by('-date')
        serializer = ArticleSerializer(articles, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = ArticleSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
from datetime import date

@require_http_methods(["GET"])
def list_articles(request):
    articles = Article.objects.all().order_by('-date')
    data = [
        {
            "title": article.title,
            "category": article.category,
            "content": article.content,
            "date": article.date.isoformat(),
            "views": article.views,
            "image": article.image.url if article.image else None
        }
        for article in articles
    ]
    return JsonResponse(data, safe=False)


@csrf_exempt
@require_http_methods(["POST"])
def create_article(request):
    title = request.POST.get("title")
    category = request.POST.get("category")
    content = request.POST.get("content")
    image = request.FILES.get("image", None)

    if not title or not category or not content:
        return JsonResponse({"error": "All fields are required"}, status=400)

    article = Article(
        title=title,
        category=category,
        content=content,
        image=image,
        date=date.today(),
        views=0
    )
    article.save()

    return JsonResponse({"message": "Article created successfully!"}, status=201)
from rest_framework import viewsets
from .serializers import ArticleSerializer

class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer