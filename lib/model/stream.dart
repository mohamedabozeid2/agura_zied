enum StreamPlatform { youtube, vimeo }

class StreamDestination {
  StreamPlatform platform;
  String url;
  StreamDestination({
    required this.platform,
    required this.url,
  });
}
