from django.urls import path
from . import views
from .views import ArticleListView, ArticleDetailView, ArticleCreateView

urlpatterns = [
    path('api/articles/', views.ArticleListView.as_view(), name='article-list'),
    path('api/articles/<int:pk>/', views.ArticleDetailView.as_view(), name='article-detail'),
    path('list/', ArticleListView.as_view(), name='article-list'),
    path('<int:pk>/', ArticleDetailView.as_view(), name='article-detail'),
    path('', ArticleCreateView.as_view(), name='article-create'),
]
