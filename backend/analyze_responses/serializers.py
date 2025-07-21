from rest_framework import serializers
from .models import Habit, Task
from datetime import date

########################################################
from rest_framework import serializers

########################################################

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['id', 'task', 'isCompleted', 'date', 'created_at']

class HabitSerializer(serializers.ModelSerializer):
    tasks = serializers.SerializerMethodField()

    class Meta:
        model = Habit
        fields = ['id', 'name', 'type', 'tasks', 'notification_status', 'reminder_time']

    def get_tasks(self, habit):
        today = date.today()
        tasks = habit.tasks.filter(date=today)
        return TaskSerializer(tasks, many=True).data
    
    def create(self, validated_data):
        user = self.context['request'].user  # ✅ get user from request
        return Habit.objects.create(user=user, **validated_data)


############################################################
