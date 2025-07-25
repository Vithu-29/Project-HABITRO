from rest_framework import serializers
from .models import Article

class ArticleSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    class Meta:
        model = Article
        fields = ['id', 'title', 'category', 'date', 'views', 'content','image']
    
    def get_image(self, obj):
        if obj.image:
            return str(obj.image)  # This gives full Cloudinary URL
        return None