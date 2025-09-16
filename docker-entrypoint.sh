#!/bin/sh
set -e

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

# Check if production environment is set
if [ "$ENVIRONMENT" = "PRODUCTION" ]; then
    echo "Starting PRODUCTION server with Gunicorn..."
    echo "Collecting static files..."
    python manage.py collectstatic --noinput
    
    # Start Gunicorn with Uvicorn workers
    exec gunicorn --bind 0.0.0.0:8000 --workers 4 --worker-class uvicorn.workers.UvicornWorker realtime_video_stream.asgi:application
else
    echo "Starting DEVELOPMENT server with Uvicorn..."
    
    # Start Uvicorn with reload enabled
    exec uvicorn realtime_video_stream.asgi:application --host 0.0.0.0 --port 8000 --reload
fi