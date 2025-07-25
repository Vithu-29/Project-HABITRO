from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status
from .models import Article
from .serializers import ArticleSerializer

class ArticleListView(generics.ListAPIView):
    queryset = Article.objects.all().order_by('-date')
    serializer_class = ArticleSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset()
        category = self.request.query_params.get('category')
        search_query = self.request.query_params.get('search')

        if category:
            queryset = queryset.filter(category=category)

        if search_query:
            queryset = queryset.filter(title__icontains=search_query)

        return queryset

class ArticleDetailView(generics.RetrieveAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        article = self.get_object()
        article.views += 1
        article.save()
        return self.retrieve(request, *args, **kwargs)
from rest_framework.parsers import MultiPartParser, FormParser

class ArticleCreateView(generics.CreateAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    parser_classes = (MultiPartParser, FormParser)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def article_categories(request):
    categories = [choice[0] for choice in Article.category_choices]
    return Response(categories)
