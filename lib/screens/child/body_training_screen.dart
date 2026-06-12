import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:step_up/app_colors.dart';
import 'package:step_up/models/exercise_model.dart';
import 'package:step_up/services/exercise_service.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  BODY TRAINING SCREEN  –  Exercise List
// ═══════════════════════════════════════════════════════════════════════════════

class BodyTrainingScreen extends StatefulWidget {
  const BodyTrainingScreen({super.key});

  @override
  State<BodyTrainingScreen> createState() => _BodyTrainingScreenState();
}

class _BodyTrainingScreenState extends State<BodyTrainingScreen>
    with TickerProviderStateMixin {
  List<ExerciseCategory> _categories = [];
  bool _isLoading = true;
  String? _error;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Category config matched to the calm child UI
  static const Map<String, IconData> _categoryIcons = {
    'Upper Body': Icons.sports_gymnastics,
    'Lower Body': Icons.directions_run_rounded,
    'Core': Icons.fitness_center_rounded,
    'Full Body': Icons.accessibility_new_rounded,
    'Full Body Cardio': Icons.favorite_rounded,
  };

  static const Map<String, String> _categoryEmoji = {
    'Upper Body': '💪',
    'Lower Body': '🦵',
    'Core': '🏋️',
    'Full Body': '🤸',
    'Full Body Cardio': '❤️‍🔥',
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fetchExercises();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchExercises() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final cats = await ExerciseService.getExercises();
      setState(() { _categories = cats; _isLoading = false; });
      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _openExercise(Exercise exercise) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => _ExerciseDetailScreen(exercise: exercise),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Same background as speech screens
      backgroundColor: const Color(0xFFE7F0FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Body Training 💪',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: _fetchExercises,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: _LoadingIndicator())
            : _error != null
                ? _buildError()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Choose an exercise to start!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ..._categories.map((cat) => _buildCategorySection(cat)),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildCategorySection(ExerciseCategory cat) {
    final icon = _categoryIcons[cat.name] ?? Icons.fitness_center_rounded;
    final emoji = _categoryEmoji[cat.name] ?? '💪';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$emoji ${cat.name}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${cat.exercises.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...cat.exercises.map((ex) => _ExerciseCard(
              exercise: ex,
              onTap: () => _openExercise(ex),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😢', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Could not load exercises!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _fetchExercises,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Try Again', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  EXERCISE CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.play_circle_fill_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.repeat_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise.targetReps} reps',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  EXERCISE DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class _ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const _ExerciseDetailScreen({required this.exercise});

  @override
  State<_ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<_ExerciseDetailScreen> {
  VideoPlayerController? _videoController;
  bool _videoReady   = false;
  bool _videoLoading = false;
  String? _videoError;
  bool _isStarting = false;
  bool _showVideo  = false;

  Future<void> _loadVideo() async {
    if (_videoLoading || _videoReady) return;
    setState(() { _videoLoading = true; _videoError = null; });
    try {
      final encodedUrl = widget.exercise.videoUrl.replaceAll(' ', '%20');
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(encodedUrl),
        httpHeaders: const {
          'ngrok-skip-browser-warning': 'true',
          'Accept': '*/*',
        },
      );
      _videoController = ctrl;
      await ctrl.initialize();
      ctrl.setLooping(true);
      ctrl.play();
      if (mounted) setState(() { _videoReady = true; _videoLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _videoLoading = false; _videoError = e.toString(); });
    }
  }

  Future<void> _retryVideo() async {
    setState(() { _videoReady = false; _videoError = null; });
    await _videoController?.dispose();
    _videoController = null;
    await _loadVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    setState(() => _isStarting = true);
    try {
      final session = await ExerciseService.startSession(widget.exercise.id);
      if (!mounted) return;
      
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => _ActiveSessionScreen(
            exercise: widget.exercise,
            session: session,
          ),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start session 😢 $e'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
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
          widget.exercise.displayName,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [AppColors.softShadow],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.sports_gymnastics,
                              size: 60, color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            widget.exercise.displayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.exercise.category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _DetailChip(
                                icon: Icons.repeat_rounded,
                                label: 'Target',
                                value: '${widget.exercise.targetReps} reps',
                              ),
                              const _DetailChip(
                                icon: Icons.smart_toy_rounded,
                                label: 'Mode',
                                value: 'AI Tracked',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Watch Demo
                    _buildDemoSection(),
                  ],
                ),
              ),
            ),

            // Start Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _isStarting ? null : _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 64),
                  elevation: 4,
                ),
                child: _isStarting
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🚀', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Text(
                            "Let's Go!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final opening = !_showVideo;
            setState(() => _showVideo = opening);
            if (opening) _loadVideo();
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [AppColors.softShadow],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watch Demo 🎬',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap to show or hide',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _showVideo
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade400,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        if (_showVideo) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildVideoArea(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoArea() {
    if (_videoError != null) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Could not load video',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _retryVideo,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_videoLoading || !_videoReady) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary, strokeWidth: 4),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final vc = _videoController!;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: vc.value.size.width,
          height: vc.value.size.height,
          child: VideoPlayer(vc),
        ),
      ),
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════════════
//  ACTIVE SESSION SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class _ActiveSessionScreen extends StatefulWidget {
  final Exercise exercise;
  final ExerciseSession session;

  const _ActiveSessionScreen({
    required this.exercise,
    required this.session,
  });

  @override
  State<_ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<_ActiveSessionScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  bool _cameraReady = false;

  int _completedReps = 0;
  bool _isCompleting = false;
  bool _sessionDone = false;

  late Stopwatch _stopwatch;
  Timer? _timerUpdater;
  String _elapsed = '00:00';

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timerUpdater = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = _formatElapsed());
    });
    
    _initCamera();
  }

  String _formatElapsed() {
    final s = _stopwatch.elapsed.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Select front camera by default
      _selectedCameraIdx = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front);
      if (_selectedCameraIdx == -1) _selectedCameraIdx = 0;

      await _setupCameraController(_cameras[_selectedCameraIdx]);
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    _cameraController = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  Future<void> _toggleCamera() async {
    if (_cameras.isEmpty || _cameras.length == 1) return;
    
    setState(() => _cameraReady = false);
    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras.length;
    await _setupCameraController(_cameras[_selectedCameraIdx]);
  }

  @override
  void dispose() {
    _timerUpdater?.cancel();
    _stopwatch.stop();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _completeSession() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    _stopwatch.stop();
    _timerUpdater?.cancel();

    try {
      final totalReps = widget.exercise.targetReps;
      final ratio = (_completedReps / totalReps).clamp(0.0, 1.0);
      final score = double.parse(ratio.toStringAsFixed(2));
      final feedback = ratio >= 0.9
          ? 'Excellent! You are a star! ⭐'
          : ratio >= 0.6
              ? 'Great job! Keep it up! 💪'
              : 'Good try! Practice makes perfect! 🎯';

      final completed = await ExerciseService.completeSession(
        sessionId: widget.session.sessionId,
        completedReps: _completedReps,
        score: score,
        feedback: feedback,
      );

      if (!mounted) return;
      setState(() => _sessionDone = true);
      _showResultDialog(completed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save result 😢 $e'),
          backgroundColor: AppColors.secondary,
        ),
      );
      setState(() => _isCompleting = false);
    }
  }

  void _showResultDialog(CompletedSession result) {
    final percent = (result.score * 100).toStringAsFixed(0);
    final isGreat = result.score >= 0.9;
    final isMid   = result.score >= 0.6;
    final emoji   = isGreat ? '🏆' : isMid ? '🎉' : '💪';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                isGreat ? 'Amazing!!' : isMid ? 'Well done!' : 'Good effort!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ResultStat(emoji: '🔁', value: '${result.completedReps}', label: 'Reps'),
                  _ResultStat(emoji: '⭐', value: '$percent%', label: 'Score'),
                  _ResultStat(emoji: '⏱️', value: _elapsed, label: 'Time'),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Text(
                  result.feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop()
                    ..pop()
                    ..pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text(
                  'Back to Exercises 🏠',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_completedReps / widget.exercise.targetReps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87, size: 28),
          onPressed: _showExitConfirmation,
        ),
        title: Text(
          widget.exercise.displayName,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Camera Flip Button
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.black87, size: 28),
            onPressed: _toggleCamera,
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [AppColors.softShadow],
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  _elapsed,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Camera View
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: (_cameraReady && _cameraController != null)
                            ? CameraPreview(_cameraController!)
                            : _buildCameraLoading(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$_completedReps / ${widget.exercise.targetReps} reps',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 16,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                height: 80,
                child: ElevatedButton(
                  onPressed: (_isCompleting || _sessionDone) ? null : _completeSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  child: _isCompleting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🏁', style: TextStyle(fontSize: 28)),
                            SizedBox(width: 12),
                            Text(
                              'Finish Exercise!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraLoading() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📷', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 4),
            SizedBox(height: 16),
            Text(
              'Camera starting...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😮', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                'Quit Exercise?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your progress won\'t be saved!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Keep Going!', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('Quit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _ResultStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.primary, strokeWidth: 4),
        SizedBox(height: 16),
        Text('Loading exercises... 🏋️',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary)),
      ],
    );
  }
}
