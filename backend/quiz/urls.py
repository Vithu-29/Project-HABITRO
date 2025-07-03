from django.urls import path
from .views import (
    GenerateQuizView,
    GetQuizView,
    UpdateProgressView,
    AddCoinsView
)

urlpatterns = [
    path('generate-quiz/', GenerateQuizView.as_view()),
    path('get-quiz/', GetQuizView.as_view()),
    path('update-progress/', UpdateProgressView.as_view()),
    path('add-coins/', AddCoinsView.as_view()),
]
