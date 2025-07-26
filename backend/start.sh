#!/usr/bin/env bash

# Start the Django app using Gunicorn on Render
gunicorn config.wsgi:application --bind 0.0.0.0:$PORT
