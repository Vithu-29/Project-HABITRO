from django.urls import path
from . import views  # or your actual views file

urlpatterns = [
    path('analyze_habit/', views.analyze_habit, name='analyze_habit'),
    path('generate_dynamic_questions/', views.generate_dynamic_questions, name='generate_dynamic_questions'),

]
