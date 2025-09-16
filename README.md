# Setup
- **Copy `.env.example` to `.env` & fill up env below**
```properties
RTSP_URL=
```

# Setup `Settings.py`
- **Add `INSTALLED_APPS`**
```python
INSTALLED_APPS = [
    ...
    'channels',
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

# Create Consumer
- **Refer to `livestreaming/consumers.py`**
- **StreamConsumer** class will be served as ASGI.

# Create Routing
- **Refer to `livestreaming/routing.py`**
- **Regex** is used to route to **Consumer class**
```python
re_path(r'ws/stream/$', consumers.StreamConsumer.as_asgi()),
```

# Configure `ASGI.py`
- **http request:** route to main `urls.py`
- **websocket request:** route to `routing.py`
```python
application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": URLRouter(livestreaming.routing.websocket_urlpatterns),
})
```

# Create Frontend Client
- **Refer to `video_stream_view` in `livestreaming/views.py`**
- Frontend websocket to stream video
