from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import HabitroAdminManager

class AdminLoginView(APIView):
    def post(self, request):
        email = request.data.get('email', '').strip()
        password = request.data.get('password', '').strip()
        
        print(f"Received email: {email}")  # Debug log
        print(f"Received password: {password[:2]}...")  # Log first 2 chars
        
        if not all([email, password]):
            return Response({"error": "Both fields required"}, status=400)

        try:
            admin_id = HabitroAdminManager.authenticate(email, password)
            if admin_id:
                request.session['admin_id'] = admin_id
                return Response({
                    "status": "success",
                    "email": email
                })
            
            return Response({"error": "Invalid credentials"}, status=401)
            
        except Exception as e:
            print(f"Auth error: {str(e)}")  # Debug log
            return Response({"error": str(e)}, status=500)