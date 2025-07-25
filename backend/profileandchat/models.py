from django.db import models
from django.conf import settings
from cryptography.fernet import Fernet
import base64
import os

class UserProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='profile'
    )

    full_name = models.CharField(max_length=255)
    email = models.EmailField(null=True, blank=True)
    phone_number = models.CharField(max_length=15, null=True, blank=True)

    dob = models.DateField(null=True, blank=True)
    gender = models.CharField(
        max_length=10,
        choices=[
            ('none', 'None'),
            ('male', 'Male'), 
            ('female', 'Female')
        ],
        null=True, blank=True
    )
    profile_pic = models.ImageField(
        upload_to='profile_pics/',
        null=True,
        blank=True,
        default='profile_pics/default.png'
    )

    def __str__(self):
        return self.full_name

class Friendship(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='friends', on_delete=models.CASCADE)
    friend = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='friend_of', on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'friend')

class ChatEncryption:
    @staticmethod
    def generate_key():
        return Fernet.generate_key()
    
    @staticmethod
    def encrypt_message(message, key):
        f = Fernet(key)
        encrypted_message = f.encrypt(message.encode())
        return base64.urlsafe_b64encode(encrypted_message).decode()
    
    @staticmethod
    def decrypt_message(encrypted_message, key):
        try:
            f = Fernet(key)
            decoded_message = base64.urlsafe_b64decode(encrypted_message.encode())
            decrypted_message = f.decrypt(decoded_message)
            return decrypted_message.decode()
        except:
            return encrypted_message  # Return as is if decryption fails

class Message(models.Model):
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='received_messages')
    encrypted_text = models.TextField()  # Store encrypted message
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)
    is_deleted_by_sender = models.BooleanField(default=False)
    is_deleted_by_receiver = models.BooleanField(default=False)
    encryption_key = models.TextField()  # Store encryption key

    class Meta:
        ordering = ['timestamp']

    def save(self, *args, **kwargs):
        if not self.encryption_key:
            self.encryption_key = base64.urlsafe_b64encode(ChatEncryption.generate_key()).decode()
        super().save(*args, **kwargs)

    @property
    def text(self):
        """Decrypt and return the message text"""
        try:
            key = base64.urlsafe_b64decode(self.encryption_key.encode())
            return ChatEncryption.decrypt_message(self.encrypted_text, key)
        except:
            return self.encrypted_text

    def set_text(self, plain_text):
        """Encrypt and set the message text"""
        if not self.encryption_key:
            self.encryption_key = base64.urlsafe_b64encode(ChatEncryption.generate_key()).decode()
        
        key = base64.urlsafe_b64decode(self.encryption_key.encode())
        self.encrypted_text = ChatEncryption.encrypt_message(plain_text, key)

    def is_visible_to_user(self, user):
        """Check if message is visible to the user (not deleted by them)"""
        if user == self.sender:
            return not self.is_deleted_by_sender
        elif user == self.receiver:
            return not self.is_deleted_by_receiver
        return False