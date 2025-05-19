from rest_framework import serializers
from .models import Quiz, UserProgress

class QuizSerializer(serializers.ModelSerializer):
    class Meta:
        model = Quiz
        fields = '__all__'

class UserProgressSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProgress
        fields = ['current_question_index']
        extra_kwargs = {
            'user_id': {'read_only': True}  # Auto-set to 1
        }