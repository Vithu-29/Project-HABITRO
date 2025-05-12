from django.http import JsonResponse

def root_view(request):
    """Simplified root endpoint without CSRF reference"""
    return JsonResponse({
        'message': 'Welcome to HABITRO API',
        'endpoints': {
            'admin_login': '/api/auth/admin-login/',  # Updated path
            'documentation': '/docs/'  # Optional: Add your API docs link
        }
    })

# Error handlers (improved version)
def handler404(request, exception):
    return JsonResponse({
        'error': 'Endpoint not found',
        'available_endpoints': ['/api/auth/admin-login/']
    }, status=404)

def handler500(request):
    return JsonResponse({
        'error': 'Internal server error',
        'support': 'contact@habitro.com'  # Optional
    }, status=500)