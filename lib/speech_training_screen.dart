import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'app_colors.dart';

class SpeechTrainingScreen extends StatefulWidget {
  final int level;

  const SpeechTrainingScreen({super.key, required this.level});

  @override
  State<SpeechTrainingScreen> createState() => _SpeechTrainingScreenState();
}

class _SpeechTrainingScreenState extends State<SpeechTrainingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (!mounted) return;

      setState(() => _isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording saved: ${path ?? 'unknown path'}')),
      );
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
        '${directory.path}/speech_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: filePath,
    );

    if (!mounted) return;
    setState(() => _isRecording = true);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _SpeechPrompt.fromLevel(widget.level);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F1FF),
      appBar: _buildAppBar(prompt.levelTitle),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7F0FF), Color(0xFFD9D7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 48
                      ? constraints.maxHeight - 48
                      : 0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildWordCard(prompt.display, prompt.word),
                      const SizedBox(height: 24),
                      _buildWaveformCard(),
                      const Spacer(),
                      const SizedBox(height: 24),
                      _buildMicrophoneSection(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String levelTitle) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Speech Training - $levelTitle',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                '0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWordCard(String display, String word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              display,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            onPressed: () {},
            icon: const Icon(
              Icons.volume_up_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            label: const Text(
              'Listen',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: _cardDecoration(),
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
    );
  }

  Widget _buildMicrophoneSection() {
    return Column(
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isCenter = index == 1;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isCenter ? 22 : 8,
              height: 6,
              decoration: BoxDecoration(
                color: isCenter ? AppColors.primary : AppColors.outline,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _SpeechPrompt {
  final String display;
  final String word;
  final String levelTitle;

  const _SpeechPrompt({
    required this.display,
    required this.word,
    required this.levelTitle,
  });

  factory _SpeechPrompt.fromLevel(int level) {
    switch (level) {
      case 0:
        return const _SpeechPrompt(
          display: 'Aa',
          word: 'Letter A',
          levelTitle: 'English Letters',
        );
      case 1:
        return const _SpeechPrompt(
          display: '/a/',
          word: '/a/ sound',
          levelTitle: 'Letter Sounds',
        );
      default:
        return const _SpeechPrompt(
          display: 'Apple',
          word: 'Apple',
          levelTitle: 'Words',
        );
    }
  }
}
