from rest_framework import serializers
from .models import Article

class ArticleSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    class Meta:
        model = Article
        fields = ['id', 'title', 'category', 'date', 'views', 'content','image']
    
    def get_image(self, obj):
        request = self.context.get('request')
        image_url = obj.image.url
        return request.build_absolute_uri(image_url) if request else image_url