#!/usr/bin/env bash

# Install all dependencies and apply migrations
pip install -r requirements.txt
python manage.py collectstatic --noinput
python manage.py migrate
