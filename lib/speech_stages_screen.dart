import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'app_colors.dart';
import 'speech_stage1_screen.dart';
import 'speech_stage2_screen.dart';
import 'speech_stage3_screen.dart';

import 'models/speech_level_content.dart';
import 'services/speech_service.dart';

class SpeechStagesScreen extends StatefulWidget {
  final int level;

  const SpeechStagesScreen({super.key, required this.level});

  @override
  State<SpeechStagesScreen> createState() => _SpeechStagesScreenState();
}

class _SpeechStagesScreenState extends State<SpeechStagesScreen> {
  final SpeechService _speechService = SpeechService();
  List<SpeechLevelContent> _levelContent = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final content = await _speechService.getLevelContent(widget.level); // Pass 1, 2, 3 etc. based on 1-indexed level
      if (mounted) {
        setState(() {
          _levelContent = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Level ${widget.level} Stages',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
              ? Center(child: Text('Error loading content: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : _levelContent.isEmpty 
                ? const Center(child: Text('No content available for this level.'))
                : Column(
            children: [
              FadeInDown(
                child: const Text(
                  'Choose a Stage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _StageCard(
                  title: 'Stage 1',
                  subtitle: 'Watch and Learn',
                  icon: Icons.play_circle_fill_rounded,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpeechStage1Screen(
                          level: widget.level,
                          contentList: _levelContent,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _StageCard(
                  title: 'Stage 2',
                  subtitle: 'Listen and Choose',
                  icon: Icons.touch_app_rounded,
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpeechStage2Screen(
                          level: widget.level,
                          contentList: _levelContent,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _StageCard(
                  title: 'Stage 3',
                  subtitle: 'Listen and Speak',
                  icon: Icons.mic_rounded,
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpeechStage3Screen(
                          level: widget.level,
                          contentList: _levelContent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StageCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
