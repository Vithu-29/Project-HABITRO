from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models
from django.utils import timezone
from django.core.validators import MinLengthValidator
from datetime import timedelta


class CustomUserManager(BaseUserManager):
    # Allow email to be None
    def create_user(self, email=None, full_name=None, password=None, phone_number=None):
        """
        Creates and saves a User with the given email, full_name and password.
        """
        if not email and not phone_number:
            raise ValueError("Users must provide an email or phone number")

        # Normalize phone number
        if phone_number:
            phone_number = self.normalize_phone_number(phone_number)

        user = self.model(
            email=self.normalize_email(email) if email else None,
            full_name=full_name,
            phone_number=phone_number
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def normalize_phone_number(self, phone):
        """Normalize phone number to +947 format"""
        if not phone:
            return phone

        # Remove all non-digit characters
        phone = ''.join(filter(str.isdigit, phone))

        # Handle Sri Lankan numbers
        if phone.startswith('0') and len(phone) == 10:  # 07XXXXXXXX
            return '+94' + phone[1:]
        elif phone.startswith('94') and len(phone) == 11:  # 947XXXXXXXX
            return '+' + phone
        elif phone.startswith('+94') and len(phone) == 12:  # +947XXXXXXXX
            return phone
        elif len(phone) == 9:  # 7XXXXXXXX (missing country code)
            return '+94' + phone
        return phone  # Return as-is if format is unexpected

    def create_superuser(self, email, full_name, password=None, phone_number=None):
        """
        Creates and saves a superuser with the given email, full_name and password.
        """
        user = self.create_user(
            email=email,
            full_name=full_name,
            password=password,
            phone_number=phone_number
        )
        user.is_admin = True
        user.save(using=self._db)
        return user


class CustomUser(AbstractBaseUser):
    email = models.EmailField(
        verbose_name='email address',
        max_length=255,
        unique=True,
        blank=True,  # Allow blank for phone users
        null=True,   # Allow null for phone users
    )
    phone_number = models.CharField(
        verbose_name='phone number',
        max_length=15,
        unique=True,
        blank=True,  # Allow blank for email users
        null=True,   # Allow null for email users
    )

    full_name = models.CharField(
        verbose_name='full name',
        max_length=255
    )
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)
    last_login = models.DateTimeField(
        blank=True, null=True)  # <-- Add this line

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
    email = models.EmailField(blank=True, null=True)
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    otp = models.CharField(max_length=6)
    full_name = models.CharField(max_length=255, blank=True)
    temp_password = models.CharField(max_length=128, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "OTP Verification"
        verbose_name_plural = "OTP Verifications"
        indexes = [
            models.Index(fields=['email', 'otp']),
            models.Index(fields=['phone_number', 'otp']),
        ]
        ordering = ['-created_at']

    def is_expired(self):
        """Check if OTP has expired (15 minute lifetime)"""
        return timezone.now() > self.created_at + timedelta(minutes=15)

    def __str__(self):
        return f"OTP for {self.email} ({'expired' if self.is_expired() else 'active'})"


class Challenge(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    category = models.CharField(max_length=100)  # e.g., "Fitness", "Nutrition"
    duration_days = models.IntegerField(default=30)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return self.title


class ChallengeHabit(models.Model):
    challenge = models.ForeignKey(
        Challenge, related_name='habits', on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    description = models.TextField()
    frequency = models.CharField(max_length=100)  # e.g., "Daily", "Weekly"

    def __str__(self):
        return f"{self.challenge.title} - {self.title}"


class UserChallenge(models.Model):
    user = models.ForeignKey(
        CustomUser, related_name='user_challenges', on_delete=models.CASCADE)
    challenge = models.ForeignKey(Challenge, on_delete=models.CASCADE)
    start_date = models.DateField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        unique_together = ('user', 'challenge')

    def __str__(self):
        return f"{self.user.email} - {self.challenge.title}"


class UserChallengeHabit(models.Model):
    user_challenge = models.ForeignKey(
        UserChallenge, related_name='habits', on_delete=models.CASCADE)
    habit = models.ForeignKey(ChallengeHabit, on_delete=models.CASCADE)
    is_completed = models.BooleanField(default=False)
    completed_date = models.DateField(null=True, blank=True)

    class Meta:
        unique_together = ('user_challenge', 'habit')

    def __str__(self):
        return f"{self.user_challenge} - {self.habit.title}"
