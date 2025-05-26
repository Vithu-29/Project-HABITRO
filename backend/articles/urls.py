from django.urls import path
from . import views

urlpatterns = [
    path('api/articles/', views.ArticleListView.as_view(), name='article-list'),
    path('api/articles/<int:pk>/', views.ArticleDetailView.as_view(), name='article-detail'),
]
