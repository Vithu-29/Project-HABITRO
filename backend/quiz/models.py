from django.db import models
from django.contrib.auth import get_user_model

class Quiz(models.Model):
    question = models.CharField(max_length=255)
    option_1 = models.CharField(max_length=100)
    option_2 = models.CharField(max_length=100)
    option_3 = models.CharField(max_length=100)
    option_4 = models.CharField(max_length=100)
    answer = models.CharField(max_length=100)

    def __str__(self):
        return self.question

class UserProgress(models.Model):
    user = models.ForeignKey(
        get_user_model(),
        on_delete=models.CASCADE,
        related_name='quiz_progress',
        null=True
    )
    current_question_index = models.IntegerField(default=0)

    def __str__(self):
        return f"User {self.user_id} - Current Question: {self.current_question_index}"
