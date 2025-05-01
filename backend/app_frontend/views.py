from rest_framework import generics
from rest_framework.response import Response
from rest_framework import status
from django.http import HttpResponse  
from .models import CustomUser
from .serializers import RegisterSerializer

# Added the missing index view
def index(request):
    return HttpResponse("Welcome to the app_frontend index page!")

class RegisterView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response({"message": "User created successfully"}, status=status.HTTP_201_CREATED)