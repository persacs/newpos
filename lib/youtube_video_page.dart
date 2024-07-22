import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeVideoPage extends StatefulWidget {
  @override
  _YouTubeVideoPageState createState() => _YouTubeVideoPageState();
}

class _YouTubeVideoPageState extends State<YouTubeVideoPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    const videoURL =
        'https://www.youtube.com/watch?v=e2Sqkeds1vw'; // Replace with your video URL
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoURL)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Video'),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
        ),
      ),
    );
  }
}
