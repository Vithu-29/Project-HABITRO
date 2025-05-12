# middleware.py
from django.utils.deprecation import MiddlewareMixin
from django.http import JsonResponse

class AdminAuthMiddleware(MiddlewareMixin):
    EXEMPT_PATHS = [
        '/',
        '/admin_auth/admin-login/',
        '/static/',
        '/media/',
    ]
    
    def process_request(self, request):
        if any(request.path.startswith(path) for path in self.EXEMPT_PATHS):
            return None
            
        if not request.session.get('admin_id'):
            return JsonResponse(
                {'error': 'Authentication required'},
                status=401
            )