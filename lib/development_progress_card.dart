import 'package:flutter/material.dart';
import 'package:step_up/models/progress_model.dart';
import 'package:step_up/services/progress_service.dart';

import 'app_colors.dart';

class DevelopmentProgressCard extends StatefulWidget {
  final String? parentId;
  const DevelopmentProgressCard({super.key, this.parentId});

  @override
  State<DevelopmentProgressCard> createState() => _DevelopmentProgressCardState();
}

class _DevelopmentProgressCardState extends State<DevelopmentProgressCard> {
  ProgressData? _localProgressData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.parentId == null) {
      ProgressService.currentProgress.addListener(_onProgressUpdated);
    }
    _fetchProgress();
  }

  @override
  void dispose() {
    if (widget.parentId == null) {
      ProgressService.currentProgress.removeListener(_onProgressUpdated);
    }
    super.dispose();
  }

  void _onProgressUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchProgress() async {
    // If we already have global data for the logged-in user, use it immediately
    if (widget.parentId == null && ProgressService.currentProgress.value != null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await ProgressService.getProgress('week', parentId: widget.parentId);
      if (mounted) {
        setState(() {
          _localProgressData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 320;
        
        final progressData = widget.parentId == null 
            ? ProgressService.currentProgress.value ?? _localProgressData
            : _localProgressData;
        final progress = progressData?.overallProgress ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProgressRing(progress: progress),
                        const SizedBox(height: 18),
                        _ProgressDetails(data: progressData),
                      ],
                    )
                  : Row(
                      children: [
                        _ProgressRing(progress: progress),
                        const SizedBox(width: 20),
                        Expanded(child: _ProgressDetails(data: progressData)),
                      ],
                    ),
        );
      },
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int progress;
  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress / 100.0,
            color: Colors.white,
            strokeWidth: 7,
            backgroundColor: Colors.white24,
          ),
          Center(
            child: Text(
              "$progress%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDetails extends StatelessWidget {
  final ProgressData? data;
  const _ProgressDetails({this.data});

  @override
  Widget build(BuildContext context) {
    final message = data != null && data!.message.isNotEmpty 
        ? data!.message 
        : "Keep up the great work!";
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Development Progress",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Speech: ${data?.speechProgress ?? 0}% | Body: ${data?.bodyProgress ?? 0}%",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
