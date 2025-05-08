from django.db import models
from django.contrib.auth.hashers import make_password, check_password
from django.core.validators import RegexValidator

class AdminUser(models.Model):
    email = models.EmailField(
        unique=True,
        validators=[
            RegexValidator(
                regex=r'^[\w\.-]+@gmail\.com$',
                message="Only Gmail addresses are allowed (e.g., example@gmail.com)"
            )
        ]
    )
    password = models.CharField(max_length=255)  # Stores hashed password
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.email
    
    def set_password(self, raw_password):
        """Hashes and stores the password"""
        self.password = make_password(raw_password)
    
    def check_password(self, raw_password):
        """Verifies the password"""
        return check_password(raw_password, self.password)
    
    @classmethod
    def create_admin(cls, email, password):
        """Creates new admin with hashed password"""
        email = email.lower().strip()
        if cls.objects.filter(email=email).exists():
            raise ValueError("Admin with this email already exists")
        
        admin = cls(email=email)
        admin.set_password(password)
        admin.save()
        return admin