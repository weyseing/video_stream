from django.shortcuts import render

def video_stream_view(request):
    return render(request, 'livestreaming/video_stream.html') 
