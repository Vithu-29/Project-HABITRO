from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models

class CustomUserManager(BaseUserManager):
    def create_user(self, email=None, phone_number=None, full_name=None, password=None):
        if not email and not phone_number:
            raise ValueError("Users must provide either an email or a phone number")
        user = self.model(
            email=self.normalize_email(email) if email else None,
            phone_number=phone_number,
            full_name=full_name
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, phone_number, full_name, password=None):
        user = self.create_user(email=email, phone_number=phone_number, full_name=full_name, password=password)
        user.is_admin = True
        user.save(using=self._db)
        return user

class CustomUser(AbstractBaseUser):
    email = models.EmailField(unique=True, null=True, blank=True)  # Email is optional
    phone_number = models.CharField(max_length=15, unique=True, null=True, blank=True)  # Phone number is optional
    full_name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'email'  # Default login field
    REQUIRED_FIELDS = ['full_name']  # Only full_name is required

    def __str__(self):
        return self.email if self.email else self.phone_number