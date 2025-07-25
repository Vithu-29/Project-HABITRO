from django.urls import path
from . import views
from .views import ArticleListView, ArticleDetailView, ArticleCreateView

urlpatterns = [
    path('', views.ArticleListView.as_view(), name='article-list'),
    path('<int:pk>/', views.ArticleDetailView.as_view(), name='article-detail'),
    path('categories/', views.article_categories, name='article-categories'),
    path('list/', ArticleListView.as_view(), name='article-list'),
    path('<int:pk>/', ArticleDetailView.as_view(), name='article-detail'),
    path('', ArticleCreateView.as_view(), name='article-create'),
]
