import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';

import 'app_colors.dart';
import 'models/speech_level_content.dart';
import 'services/speech_service.dart';

class SpeechStage2Screen extends StatefulWidget {
  final int level;
  final List<SpeechLevelContent> contentList;

  const SpeechStage2Screen({super.key, required this.level, required this.contentList});

  @override
  State<SpeechStage2Screen> createState() => _SpeechStage2ScreenState();
}

class _SpeechStage2ScreenState extends State<SpeechStage2Screen> {
  int _currentLetterIndex = 0;
  
  bool _isAudioPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isProcessingAnswer = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  final SpeechService _speechService = SpeechService();

  void _playAudio() async {
    if (widget.contentList.isEmpty) return;
    
    final currentItem = widget.contentList[_currentLetterIndex];
    if (currentItem.audioUrl.isNotEmpty) {
      try {
        final localPath = await _speechService.downloadReferenceAudio(currentItem.audioUrl);
        if (localPath != null) {
          await _audioPlayer.play(DeviceFileSource(localPath));
        } else {
          await _audioPlayer.play(UrlSource(currentItem.audioUrl));
        }
      } catch (e) {
        print("Error playing audio: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not play audio')),
          );
        }
      }
    }
  }

  void _showAnimationOverlay(bool isCorrect) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: isCorrect
              ? FadeIn(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.greenAccent.withValues(alpha: 0.95),
                          Colors.green.shade800.withValues(alpha: 0.98)
                        ],
                        center: Alignment.center,
                        radius: 1.2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(top: 100, left: 40, child: ZoomIn(delay: const Duration(milliseconds: 200), child: const Icon(Icons.star, color: Colors.yellow, size: 60))),
                        Positioned(top: 180, right: 50, child: ZoomIn(delay: const Duration(milliseconds: 400), child: const Icon(Icons.star, color: Colors.amber, size: 90))),
                        Positioned(bottom: 200, left: 60, child: ZoomIn(delay: const Duration(milliseconds: 600), child: const Icon(Icons.star, color: Colors.yellowAccent, size: 50))),
                        Positioned(bottom: 150, right: 70, child: ZoomIn(delay: const Duration(milliseconds: 300), child: const Icon(Icons.star, color: Colors.orange, size: 70))),
                        Positioned(top: 300, left: 20, child: ZoomIn(delay: const Duration(milliseconds: 500), child: const Icon(Icons.star_border, color: Colors.white, size: 40))),
                        
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BounceInDown(
                              duration: const Duration(milliseconds: 1200),
                              child: Pulse(
                                infinite: true,
                                child: const Text('🏆', style: TextStyle(fontSize: 160)),
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElasticIn(
                              delay: const Duration(milliseconds: 600),
                              child: const Text(
                                'AMAZING!',
                                style: TextStyle(
                                  fontSize: 54,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                  shadows: [Shadow(color: Colors.black26, offset: Offset(0, 5), blurRadius: 10)],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : FadeIn(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.redAccent.withValues(alpha: 0.95),
                          Colors.red.shade900.withValues(alpha: 0.98)
                        ],
                        center: Alignment.center,
                        radius: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShakeX(
                          duration: const Duration(milliseconds: 800),
                          child: const Icon(Icons.cancel_rounded, color: Colors.white, size: 160),
                        ),
                        const SizedBox(height: 30),
                        FadeInUp(
                          child: const Text(
                            'Try Again!',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _onImageSelected(bool isCorrect) async {
    if (_isProcessingAnswer) return;
    
    setState(() {
      _isProcessingAnswer = true;
    });

    _showAnimationOverlay(isCorrect);
    
    if (isCorrect) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;
      Navigator.pop(context); // Close the animation dialog
      
      await _audioPlayer.stop();
      if (_currentLetterIndex < widget.contentList.length - 1) {
        setState(() {
          _currentLetterIndex++;
          _isProcessingAnswer = false;
        });
      } else {
        setState(() {
          _isProcessingAnswer = false;
        });
        _showCompletionDialog();
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      Navigator.pop(context); // Close the animation dialog
      setState(() {
        _isProcessingAnswer = false;
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Stage 2 Complete!'),
        content: const Text('You have successfully identified all letters.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to stages
            },
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contentList.isEmpty) return const Scaffold(body: Center(child: Text('No content available')));
    
    final currentItem = widget.contentList[_currentLetterIndex];
    
    // Randomize correct option position
    bool correctIsLeft = _currentLetterIndex % 2 == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F1FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Stage 2: Listen & Choose',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
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
                key: ValueKey('title-$_currentLetterIndex'),
                child: const Text(
                  'Listen to the sound and choose the correct image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Play Audio Button
              GestureDetector(
                onTap: _isAudioPlaying ? null : _playAudio,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isAudioPlaying ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: _isAudioPlaying ? 20 : 10,
                        spreadRadius: _isAudioPlaying ? 5 : 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isAudioPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _OptionCard(
                    imageUrl: correctIsLeft ? currentItem.correctImageUrl : currentItem.wrongImageUrl,
                    fallbackLetter: correctIsLeft ? currentItem.letter : '?',
                    onTap: () => _onImageSelected(correctIsLeft),
                  ),
                  _OptionCard(
                    imageUrl: !correctIsLeft ? currentItem.correctImageUrl : currentItem.wrongImageUrl,
                    fallbackLetter: !correctIsLeft ? currentItem.letter : '?',
                    onTap: () => _onImageSelected(!correctIsLeft),
                  ),
                ],
              ),
              const Spacer(),
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

class _OptionCard extends StatelessWidget {
  final String imageUrl;
  final String fallbackLetter;
  final VoidCallback onTap;

  const _OptionCard({
    required this.imageUrl,
    required this.fallbackLetter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FadeInUp(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallback(),
                )
              : _buildFallback(),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        fallbackLetter,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
