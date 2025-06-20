from rest_framework import generics
from rest_framework.response import Response
from .models import Article
from .serializers import ArticleSerializer
from rest_framework.decorators import api_view
from rest_framework import status

class ArticleListView(generics.ListAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        category = self.request.query_params.get('category', None)
        search_query = self.request.query_params.get('search', None)
        if category:
            queryset = queryset.filter(category=category)
        
        if search_query:
            queryset = queryset.filter(title__icontains=search_query)
        return queryset

class ArticleDetailView(generics.RetrieveAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer

    def get(self, request, *args, **kwargs):
        article = self.get_object()
        article.views += 1
        article.save()
        return self.retrieve(request, *args, **kwargs)
