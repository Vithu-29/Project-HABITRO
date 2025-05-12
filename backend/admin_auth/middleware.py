from django.utils.deprecation import MiddlewareMixin
from django.http import JsonResponse

class AdminAuthMiddleware(MiddlewareMixin):
    EXEMPT_PATHS = [
        '/',
        '/admin_auth/admin-login/',
        '/admin_auth/forgot-password/',
        '/admin_auth/verify-otp/',
        '/admin_auth/reset-password/',
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