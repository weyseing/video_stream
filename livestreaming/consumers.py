import os
import asyncio
from channels.generic.websocket import AsyncWebsocketConsumer

class StreamConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()
        self.stream_task = asyncio.create_task(self.stream_video())

    async def disconnect(self, close_code):
        if self.stream_task:
            self.stream_task.cancel()

    async def stream_video(self):
        ffmpeg_command = [
            "ffmpeg",
            "-rtsp_transport", "tcp",
            "-i", os.getenv('RTSP_URL'),
            "-f", "mjpeg",
            "-q:v", "5",
            "-"
        ]
        
        process = None
        try:
            process = await asyncio.create_subprocess_exec(
                *ffmpeg_command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.DEVNULL
            )

            buffer = b""
            while True:
                chunk = await process.stdout.read(1024)
                if not chunk:
                    break
                buffer += chunk

                while b"\xff\xd9" in buffer:
                    frame_end = buffer.find(b"\xff\xd9") + 2
                    frame = buffer[:frame_end]
                    buffer = buffer[frame_end:]
                    await self.send(bytes_data=frame)

        except asyncio.CancelledError:
            pass
        except Exception as e:
            print(f"Streaming error: {e}")
        finally:
            if process and process.returncode is None:
                process.kill()
                await process.wait() 
            print("FFmpeg process terminated.")

