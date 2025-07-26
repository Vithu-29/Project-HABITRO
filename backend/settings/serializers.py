from rest_framework import serializers
from .models import UserAppearanceSetting

class UserAppearanceSettingSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserAppearanceSetting
        fields = ['font_size']
