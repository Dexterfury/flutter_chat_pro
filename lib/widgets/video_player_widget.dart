import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.color,
    required this.viewOnly,
  });

  final String videoUrl;
  final Color color;
  final bool viewOnly;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late CachedVideoPlayerController videoPlayerController;
  bool isPlaying = false;
  bool isLoading = true;

  @override
  void initState() {
    videoPlayerController = CachedVideoPlayerController.network(
      widget.videoUrl,
    )
      ..addListener(() {})
      ..initialize().then((_) {
        videoPlayerController.setVolume(1);
        setState(() {
          isLoading = false;
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CachedVideoPlayer(videoPlayerController),
          Center(
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.color,
              ),
              onPressed: widget.viewOnly
                  ? null
                  : () {
                      setState(() {
                        isPlaying = !isPlaying;
                        isPlaying
                            ? videoPlayerController.play()
                            : videoPlayerController.pause();
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }
}
