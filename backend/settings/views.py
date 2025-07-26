from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import UserAppearanceSetting
from .serializers import UserAppearanceSettingSerializer

class FontSizePreferenceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Get or create settings for the user
        try:
            setting = request.user.appearance_settings
        except UserAppearanceSetting.DoesNotExist:
            setting = UserAppearanceSetting.objects.create(user=request.user)
        
        serializer = UserAppearanceSettingSerializer(setting)
        return Response(serializer.data)

    def post(self, request):
        try:
            setting = request.user.appearance_settings
        except UserAppearanceSetting.DoesNotExist:
            setting = UserAppearanceSetting.objects.create(user=request.user)

        serializer = UserAppearanceSettingSerializer(setting, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)
