#!/bin/sh
set -e

if [ "$ENVIRONMENT" = "PRODUCTION" ]; then
    gunicorn --bind 0.0.0.0:8000 --workers 4 --worker-class uvicorn.workers.UvicornWorker realtime_video_stream.asgi:application &
    nginx -g "daemon off;" -c /etc/nginx/conf.d/nginx.conf
else
    uvicorn realtime_video_stream.asgi:application --host 0.0.0.0 --port 8000 --reload
fi