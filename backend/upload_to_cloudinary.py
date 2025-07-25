import os
import django
import cloudinary.uploader

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

# Import each model from its own app
from achievements.models import Achievement
from articles.models import Article
from profileandchat.models import UserProfile

cloudinary.config(
    cloud_name='dopihatmz',
    api_key='628249634485169',
    api_secret='tzY-9xB_wXUNeXh9x_UrGMtHKRA'
)

def upload_and_update(model, image_field_name, local_folder):
    media_root = 'media'  # adjust if needed
    for obj in model.objects.all():
        current_path = getattr(obj, image_field_name).name  # relative path like achievements/day3.png

        if current_path.startswith('http'):
            print(f"Skipping {current_path}, already uploaded.")
            continue

        local_path = os.path.join(media_root, current_path)
        if os.path.exists(local_path):
            print(f"Uploading {local_path} ...")
            result = cloudinary.uploader.upload(local_path, folder=local_folder)
            setattr(obj, image_field_name, result['secure_url'])
            obj.save()
            print(f"Updated {obj} with {result['secure_url']}")
        else:
            print(f"File not found: {local_path}")

# Run upload for each model separately
upload_and_update(Achievement, 'image', 'achievements')
upload_and_update(Article, 'image', 'articles')
upload_and_update(UserProfile, 'profile_pic', 'profile_pics')
