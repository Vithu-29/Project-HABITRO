from rest_framework import serializers
from .models import Habit, Task
from datetime import date
from .models import UserCoins,CoinTransaction
########################################################
from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
########################################################

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['id', 'task', 'isCompleted', 'date', 'created_at']

class HabitSerializer(serializers.ModelSerializer):
    tasks = serializers.SerializerMethodField()

    class Meta:
        model = Habit
        fields = ['id', 'name', 'type', 'tasks']

    def get_tasks(self, habit):
        today = date.today()
        tasks = habit.tasks.filter(date=today)
        return TaskSerializer(tasks, many=True).data


############################################################
class CoinSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserCoins
        fields = ['balance']

class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoinTransaction
        fields = ['amount', 'reason', 'created_at']

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Username is already taken.")
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email'),
            password=validated_data['password']
        )
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        user = authenticate(**data)
        if user and user.is_active:
            return user
        raise serializers.ValidationError("Invalid credentials")
