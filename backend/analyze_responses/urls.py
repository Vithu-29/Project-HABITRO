from django.urls import path
from .views import analyze_responses
from .views import save_tasks
from .views import HabitsWithTodayTasks,update_task_status
from .views import task_completion_stats,  get_habits  # Add get_habits
from .views import get_coin_balance,add_coins,deduct_coins,get_profile_stats
from .views import delete_habit,update_reminder_settings



urlpatterns = [
    path('analyze_responses/', analyze_responses, name='analyze_responses'),
    path('save_tasks/', save_tasks, name='save_tasks'),
    path('habits-today/', HabitsWithTodayTasks.as_view(), name='habits_today'),
    path('task/<int:task_id>/update_task_status/', update_task_status, name='update_task_status'),
    path('task_completion_stats/',task_completion_stats, name='habits_today'),
    #path('register/', RegisterView.as_view(), name='register'),
    #path('login/', LoginView.as_view(), name='login'),
    path('get_habits/', get_habits, name='get_habits'),  # New endpoint
    path('coins/balance/', get_coin_balance, name='coin_balance'),
    path('coins/add/', add_coins, name='add_coins'),
    path('coins/deduct/', deduct_coins, name='deduct_coins'),
    path('stats/', get_profile_stats, name='profile-stats'),
    path('habits/delete/<uuid:habit_id>/', delete_habit, name='delete_habit'),
    path('update_reminder_settings/', update_reminder_settings, name='update_reminder_settings'),
]