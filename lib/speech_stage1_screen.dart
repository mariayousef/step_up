import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player/video_player.dart';

import 'app_colors.dart';
import 'models/speech_level_content.dart';
import 'dart:io';
import 'package:step_up/services/video_cache_service.dart';

class SpeechStage1Screen extends StatefulWidget {
  final int level;
  final List<SpeechLevelContent> contentList;

  const SpeechStage1Screen({super.key, required this.level, required this.contentList});

  @override
  State<SpeechStage1Screen> createState() => _SpeechStage1ScreenState();
}

class _SpeechStage1ScreenState extends State<SpeechStage1Screen> {
  int _currentLetterIndex = 0;
  
  // 0: Video 1 Repeat 1, 1: Video 1 Repeat 2
  // 2: Video 2 Repeat 1, 3: Video 2 Repeat 2
  int _currentVideoStep = 0;

  VideoPlayerController? _videoController;
  bool _isVideoInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (widget.contentList.isEmpty) return;

    if (mounted) {
      setState(() {
        _isVideoInitializing = true;
      });
    }

    final currentItem = widget.contentList[_currentLetterIndex];
    final isVideo1 = _currentVideoStep < 2;
    final url = isVideo1 ? currentItem.videoUrl : currentItem.videoUrl2;

    final oldController = _videoController;
    _videoController = null;
    await oldController?.dispose();

    String secureUrl = url.startsWith('http://') 
        ? url.replaceFirst('http://', 'https://') 
        : url;

    if (secureUrl.isNotEmpty) {
      try {
        final File? cachedFile = await VideoCacheService.prefetchVideo(secureUrl);
        
        if (cachedFile != null && await cachedFile.exists()) {
          final controller = VideoPlayerController.file(cachedFile);
          await controller.initialize();
          controller.play();
          _videoController = controller;
        } else {
          // Fallback to network if caching fails
          final controller = VideoPlayerController.networkUrl(
            Uri.parse(secureUrl),
            httpHeaders: {'ngrok-skip-browser-warning': 'true'},
          );
          await controller.initialize();
          controller.play();
          _videoController = controller;
        }
      } catch (e) {
        print("Error loading video: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isVideoInitializing = false;
      });
    }
  }

  void _nextStep() {
    if (_currentVideoStep < 3) {
      setState(() {
        _currentVideoStep++;
      });
      _initializeVideo();
    } else {
      if (_currentLetterIndex < widget.contentList.length - 1) {
        setState(() {
          _currentLetterIndex++;
          _currentVideoStep = 0;
        });
        _initializeVideo();
      } else {
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Stage 1 Complete!'),
        content: const Text('You have watched all the videos for this stage.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to stages
            },
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contentList.isEmpty) return const Scaffold(body: Center(child: Text('No content available')));
    
    final currentItem = widget.contentList[_currentLetterIndex];
    final isVideo1 = _currentVideoStep < 2;
    final repeatNumber = (_currentVideoStep % 2) + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F1FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Stage 1: Letter ${currentItem.letter}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7F0FF), Color(0xFFD9D7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                key: ValueKey('$_currentLetterIndex-$_currentVideoStep'),
                child: Text(
                  'Video ${isVideo1 ? 1 : 2} - Repeat $repeatNumber',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Video Player
              FadeIn(
                key: ValueKey('video-$_currentLetterIndex-$_currentVideoStep'),
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _isVideoInitializing
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _videoController != null && _videoController!.value.isInitialized
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                  if (!_videoController!.value.isPlaying)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 64),
                                    ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Text(
                                'Video not available',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _currentVideoStep == 3 && _currentLetterIndex == widget.contentList.length - 1
                      ? 'Finish'
                      : 'Next Play',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.contentList.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentLetterIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentLetterIndex
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
