from django.db import models
from cloudinary_storage.storage import MediaCloudinaryStorage
class Article(models.Model):
    category_choices = [
        ('Personal Development', 'Personal Development'),
        ('Productivity', 'Productivity'),
        ('Technology', 'Technology'),
        ('Health and Fitness', 'Health and Fitness'),
        ('Mental Well-Being', 'Mental Well-Being'),
    ]

    title = models.CharField(max_length=200)
    category = models.CharField(max_length=50, choices=category_choices)
    content = models.TextField()
    date = models.DateField(auto_now_add=True)
    views = models.IntegerField(default=0)
    image = models.ImageField(upload_to='articles/',storage=MediaCloudinaryStorage(), null=True, blank=True)

    def __str__(self):
        return self.title
