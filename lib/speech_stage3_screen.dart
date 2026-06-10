import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';

import 'app_colors.dart';
import 'models/speech_level_content.dart';
import 'services/speech_service.dart';

class SpeechStage3Screen extends StatefulWidget {
  final int level;
  final List<SpeechLevelContent> contentList;

  const SpeechStage3Screen({super.key, required this.level, required this.contentList});

  @override
  State<SpeechStage3Screen> createState() => _SpeechStage3ScreenState();
}

class _SpeechStage3ScreenState extends State<SpeechStage3Screen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final SpeechService _speechService = SpeechService();
  
  int _currentLetterIndex = 0;

  bool _isRecording = false;
  String? _recordedFilePath;
  bool _isAnalyzing = false;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingReference = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingReference = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _playReferenceAudio() async {
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
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/speech_stage3_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: filePath,
    );

    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recordedFilePath = null;
    });
  }

  Future<void> _sendToBackend() async {
    if (_recordedFilePath == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final currentItem = widget.contentList[_currentLetterIndex];
      String? refPath;
      
      // Download reference audio if URL is provided
      if (currentItem.audioUrl.isNotEmpty) {
        refPath = await _speechService.downloadReferenceAudio(currentItem.audioUrl);
      }
      
      if (refPath == null) {
        throw Exception("Reference audio could not be loaded");
      }

      final response = await _speechService.submitSpeechScore(
        referenceAudioPath: refPath,
        childAudioPath: _recordedFilePath!,
      );

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      _showScoreAnimation(response);
      
      bool isPassed = response.score > 5.0;
      
      if (isPassed) {
        await Future.delayed(const Duration(milliseconds: 3000));
        if (!mounted) return;
        Navigator.pop(context); // Close dialog
        _moveToNextLetter();
      } else {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (!mounted) return;
        Navigator.pop(context); // Close dialog
        setState(() {
          _recordedFilePath = null; // Let them record again
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing speech: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showScoreAnimation(SpeechScoreResponse response) {
    double score = response.score;
    bool isPassed = score > 5.0;
    
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: isPassed
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
                                child: const Text('🌟', style: TextStyle(fontSize: 140)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElasticIn(
                              delay: const Duration(milliseconds: 600),
                              child: Column(
                                children: [
                                  const Text(
                                    'GREAT JOB!',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      shadows: [Shadow(color: Colors.black26, offset: Offset(0, 5), blurRadius: 10)],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Score: ${score.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellowAccent,
                                    ),
                                  ),
                                ],
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
                          Colors.orangeAccent.withValues(alpha: 0.95),
                          Colors.deepOrange.shade900.withValues(alpha: 0.98)
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
                          child: const Icon(Icons.mic_none_rounded, color: Colors.white, size: 140),
                        ),
                        const SizedBox(height: 30),
                        FadeInUp(
                          child: Column(
                            children: [
                              const Text(
                                'Keep Trying!',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Score: ${score.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
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

  void _moveToNextLetter() async {
    await _audioPlayer.stop();
    setState(() {
      _recordedFilePath = null;
    });

    if (_currentLetterIndex < widget.contentList.length - 1) {
      setState(() {
        _currentLetterIndex++;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Stage 3 Complete!'),
        content: const Text('You have finished all recording tasks.'),
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
          'Stage 3: Listen & Speak',
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
            children: [
              FadeInDown(
                key: ValueKey('title-$_currentLetterIndex'),
                child: Text(
                  'Listen to the letter \'${currentItem.letter}\' and repeat',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Letter Display with Play Audio Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        currentItem.letter,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _isPlayingReference ? null : _playReferenceAudio,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isPlayingReference ? AppColors.primary.withValues(alpha: 0.5) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlayingReference ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                        color: _isPlayingReference ? Colors.white : AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Waveform Dummy
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(12, (index) {
                    final height = _isRecording
                        ? ((index % 3) + 1) * 12.0
                        : ((index % 2) + 1) * 6.0;
                    final opacity = _isRecording ? 0.9 : 0.5;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 6,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: opacity),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              // Actions
              if (_isAnalyzing)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyzing pronunciation...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else if (_recordedFilePath != null)
                FadeInUp(
                  child: ElevatedButton.icon(
                    onPressed: _sendToBackend,
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text('Send for Feedback'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.redAccent : AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.redAccent : AppColors.primary)
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isRecording ? 'Tap to stop' : 'Tap to record',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
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
