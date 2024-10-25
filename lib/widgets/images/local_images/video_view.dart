import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({
    super.key,
    required this.videoFile,
  });

  final Future<File?> videoFile;

  @override
  State createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late final VideoPlayerController _videoPlayerController;
  late final ChewieController _chewieController;
  late final Chewie videoPlayerWidget;
  bool initialized = false;

  _initVideo() async {
    final video = await widget.videoFile;
    _videoPlayerController = VideoPlayerController.file(video!)
      ..setLooping(true)
      ..initialize().then(
            (_) => setState(() => initialized = true),
      );
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      allowFullScreen: true,
      allowMuting: true,
    );

    videoPlayerWidget = Chewie(
      controller: _chewieController,
    );
  }

  @override
  void initState() {
    _initVideo();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: initialized
          ? Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: videoPlayerWidget,
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 20),
                  _buildSeekBar(),
                ],
              ),
            ),
          ),
        ],
      )
          : const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _buildSeekBar() {
    return VideoProgressIndicator(
      _videoPlayerController,
      allowScrubbing: true,
      padding: const EdgeInsets.symmetric(vertical: 10),
      colors: VideoProgressColors(
        playedColor: Colors.blueAccent,
        backgroundColor: Colors.white.withOpacity(0.3),
      ),
    );
  }
}
