import os
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application
import livestreaming.routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'realtime_video_stream.settings')

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": URLRouter(livestreaming.routing.websocket_urlpatterns),
})