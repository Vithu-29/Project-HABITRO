from rest_framework import serializers
from .models import Achievement, UserAchievement

class AchievementSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()

    class Meta:
        model = Achievement
        fields = ['id', 'title', 'description', 'image']

    def get_image(self, obj):
        return obj.image.url if obj.image else ""

class UserAchievementSerializer(serializers.ModelSerializer):
    achievement = AchievementSerializer()  # nested achievement details

    class Meta:
        model = UserAchievement
        fields = ['unlocked', 'is_collected', 'achievement']
