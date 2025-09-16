# Setup Backend Streaming

## `Settings.py` Setup: -
- **Add `INSTALLED_APPS`**
```python
INSTALLED_APPS = [
    ...
    'channels',
    'livestreaming',
]
```

- **Add `ASGI_APPLICATION` and `CHANNEL_LAYERS`**
    - Must change `<YOUR_DJANGO_PROJECT_NAME>.asgi.application` below
```python
ASGI_APPLICATION = 'realtime_video_stream.asgi.application'

CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels.layers.InMemoryChannelLayer"
    },
}
```