from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models
from django.utils import timezone
from django.core.validators import MinLengthValidator
from datetime import timedelta
from django.db.models import DurationField
class CustomUserManager(BaseUserManager):
    def create_user(self, email, full_name=None, password=None):
        """
        Creates and saves a User with the given email, full_name and password.
        """
        if not email:
            raise ValueError("Users must provide an email")
        
        user = self.model(
            email=self.normalize_email(email),
            full_name=full_name
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, full_name, password=None):
        """
        Creates and saves a superuser with the given email, full_name and password.
        """
        user = self.create_user(
            email=email,
            full_name=full_name,
            password=password
        )
        user.is_admin = True
        user.save(using=self._db)
        return user

class CustomUser(AbstractBaseUser):
    email = models.EmailField(
        verbose_name='email address',
        max_length=255,
        unique=True,
    )
    
    full_name = models.CharField(
        verbose_name='full name',
        max_length=255
    )
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)
    active_time = models.DurationField(default=timedelta(0))
    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']

    def __str__(self):
        return self.email

    def has_perm(self, perm, obj=None):
        "Does the user have a specific permission?"
        return True

    def has_module_perms(self, app_label):
        "Does the user have permissions to view the app `app_label`?"
        return True

    @property
    def is_staff(self):
        "Is the user a member of staff?"
        return self.is_admin

class OTPVerification(models.Model):
    email = models.EmailField()
    otp = models.CharField(max_length=6)
    full_name = models.CharField(max_length=255, blank=True)
    temp_password = models.CharField(max_length=128, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    full_name = models.CharField(
        verbose_name='full name',
        max_length=255,
        default="Unknown User"
    )
    
    password = models.CharField(
        verbose_name='password hash',
        max_length=128,
        editable=False,
        default="default_password"
    )
    created_at = models.DateTimeField(
        verbose_name='created at',
        auto_now_add=True
    )
    
    class Meta:
        verbose_name = "OTP Verification"
        verbose_name_plural = "OTP Verifications"
        indexes = [
            models.Index(fields=['email', 'otp']),
        ]
        ordering = ['-created_at']

    def is_expired(self):
        """Check if OTP has expired (15 minute lifetime)"""
        return timezone.now() > self.created_at + timedelta(minutes=15)

    def __str__(self):
        return f"OTP for {self.email} ({'expired' if self.is_expired() else 'active'})"