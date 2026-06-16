import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:step_up/app_colors.dart';
import 'package:step_up/models/exercise_model.dart';
import 'package:step_up/services/exercise_service.dart';
import 'package:step_up/services/ai_service.dart';
import 'package:step_up/services/api_service.dart';
import 'package:step_up/config/ai_config.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_up/services/video_cache_service.dart';
import 'package:image/image.dart' as img_lib;
import 'dart:io';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart';
import 'package:step_up/services/progress_service.dart';
import 'package:step_up/services/users_data_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    if (_videoLoading || _videoReady) return;
    if (mounted) setState(() { _videoLoading = true; _videoError = null; });
    try {
      String secureUrl = widget.exercise.videoUrl.startsWith('http://') 
          ? widget.exercise.videoUrl.replaceFirst('http://', 'https://') 
          : widget.exercise.videoUrl;
      final encodedUrl = secureUrl.replaceAll(' ', '%20');
      
      // Get the video file (it will download it if not cached yet)
      final File? cachedFile = await VideoCacheService.prefetchVideo(encodedUrl);
      
      VideoPlayerController ctrl;
      if (cachedFile != null && await cachedFile.exists()) {
        ctrl = VideoPlayerController.file(cachedFile);
      } else {
        // Fallback to network if caching fails
        ctrl = VideoPlayerController.networkUrl(
          Uri.parse(encodedUrl),
          httpHeaders: const {
            'ngrok-skip-browser-warning': 'true',
            'Accept': '*/*',
          },
        );
      }

      _videoController = ctrl;
      await ctrl.initialize();
      ctrl.setLooping(true);
      if (_showVideo) ctrl.play();
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
      // Get child ID from users-data if available, otherwise fallback
      String userId = "child_001";
      try {
        final usersData = await UsersDataService.fetchUsersData();
        if (usersData.data.children.isNotEmpty) {
          userId = usersData.data.children.first.id.toString();
        } else {
          final user = await ApiService.getUser();
          userId = user != null ? user['id'].toString() : "child_001";
        }
      } catch (e) {
        final user = await ApiService.getUser();
        userId = user != null ? user['id'].toString() : "child_001";
      }

      // Start session on Main Backend (Laravel) to get a database record ID (int)
      final laravelSessionId = await ExerciseService.startSession(
        widget.exercise.id,
        widget.exercise.targetReps,
      );

      // Temporary Mapping: AI Server expects specific IDs for exercises
      int aiExpectedId = widget.exercise.id;
      final exName = widget.exercise.name.toLowerCase();
      if (exName.contains('jumping') || exName.contains('jack')) {
        aiExpectedId = 1;
      } else if (exName.contains('lunge')) {
        aiExpectedId = 2;
      } else if (exName.contains('squat')) {
        aiExpectedId = 3;
      } else if (exName.contains('pull') && exName.contains('up')) {
        aiExpectedId = 4;
      } else if (exName.contains('punch')) {
        aiExpectedId = 5;
      } else if (exName.contains('wall') && exName.contains('push')) {
        aiExpectedId = 6;
      }

      // Start session on AI Server to get a tracking ID (String sess_xxx)
      final aiSessionId = await AiService.startAiSession(
        userId: userId,
        exerciseId: aiExpectedId,
        targetReps: widget.exercise.targetReps,
      );
      if (!mounted) return;
      
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => _ActiveSessionScreen(
            exercise: widget.exercise,
            aiSessionId: aiSessionId,
            laravelSessionId: laravelSessionId,
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
            if (opening) {
              if (_videoReady) {
                _videoController?.play();
              } else {
                _loadVideo();
              }
            } else {
              _videoController?.pause();
            }
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
  final String aiSessionId;
  final int laravelSessionId;

  const _ActiveSessionScreen({
    required this.exercise,
    required this.aiSessionId,
    required this.laravelSessionId,
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

  // WebSocket & Streaming
  WebSocketChannel? _wsChannel;
  Timer? _frameTimer;
  bool _isProcessingFrame = false;
  String _aiFeedbackText = '';
  List<PoseLandmark> _landmarks = [];
  double _visibilityRatio = 0.0;
  bool _bodyDetected = false;
  String _debugError = '';
  
  int _sentFrames = 0;
  DateTime _fpsStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timerUpdater = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = _formatElapsed());
    });
    
    // Connect WebSocket FIRST, then initialize camera
    _initWebSocket();
    _initCamera();
  }

  void _initWebSocket() {
    try {
      final wsUrl = Uri.parse(
          '${AiConfig.wsBaseUrl}/ws/${widget.aiSessionId}?api_key=${AiConfig.apiKey}');
      
      debugPrint('🔌 [WS] Connecting to: $wsUrl');
      
      // Ensure ping is sent every 30 seconds to prevent timeout
      _wsChannel = IOWebSocketChannel.connect(wsUrl, pingInterval: const Duration(seconds: 30));
      
      _wsChannel!.stream.listen(
        (message) {
          debugPrint('📩 [WS] Received: ${message.toString().substring(0, message.toString().length.clamp(0, 200))}');
          _handleAiResponse(message.toString());
        },
        onError: (e) {
          debugPrint('❌ [WS] Stream Error: $e');
        },
        onDone: () {
          debugPrint('🔒 [WS] Connection closed (onDone). closeCode=${_wsChannel?.closeCode}, closeReason=${_wsChannel?.closeReason}');
        },
      );
      
      debugPrint('✅ [WS] Channel created, waiting for connection...');
    } catch (e) {
      debugPrint('❌ [WS] Connect error: $e');
    }
  }

  void _handleAiResponse(String message) {
    if (!mounted) return;
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final type = data['type'] as String?;

      debugPrint('🤖 [AI] Response type: $type');

      // AI sends session_ended when target reps reached or 60s inactivity
      if (type == 'session_ended') {
        debugPrint('🏁 [AI] Session ended! Data: $data');
        _handleSessionEnded(data);
        return;
      }

      bool updated = false;

      // AI frame_result format:
      // {"type": "frame_result", "reps": {"total": 3, "correct": 3, "remaining": 7, "session_complete": false}, ...}
      if (type == 'frame_result') {
        // Read reps from nested 'reps' object
        if (data.containsKey('reps') && data['reps'] is Map) {
          final repsData = data['reps'] as Map<String, dynamic>;
          int? parsedReps = (repsData['total'] as num?)?.toInt() ?? 
                            (repsData['count'] as num?)?.toInt() ?? 
                            (repsData['correct'] as num?)?.toInt() ?? 
                            (repsData['completed'] as num?)?.toInt();
          
          int newReps = parsedReps ?? _completedReps;

          // Check if AI says session is complete based on target reps
          if (repsData['session_complete'] == true) {
            debugPrint('🏁 [AI] session_complete flag received in frame_result!');
            // Stop sending frames immediately by setting sessionDone
            _sessionDone = true;
            try {
              _cameraController?.stopImageStream();
            } catch (_) {}
          }
          
          if (data['completed_rep'] == true && parsedReps == null) {
             newReps = _completedReps + 1;
          }

          if (newReps > _completedReps) {
            debugPrint('🔢 [AI] Rep count changed: $_completedReps → $newReps');
            _completedReps = newReps;
            updated = true;
          }
        } else if (data['completed_rep'] == true) {
          // Safe check for completed_rep if reps object is missing
          _completedReps++;
          updated = true;
          debugPrint('✨ [AI] Rep completed! Total: $_completedReps');
        }

        // feedback format: {"feedback": {"severity": "info", "message_key": "position_yourself", "text": {"ar": "...", "en": "..."}}}
        if (data.containsKey('feedback')) {
          final feedbackInfo = data['feedback'];
          if (feedbackInfo is Map) {
            String? customMessage;
            final messageKey = feedbackInfo['message_key'] as String?;
            if (messageKey == 'position_yourself' || messageKey == 'landmarks_hidden') {
              customMessage = "أرجوك اقف في نص الشاشة بحيث جسمك كله يكون باين من فوق لتحت، واتأكد إن الإضاءة كويسة ومفيش حاجة بتشتت الكاميرا!";
            }

            if (customMessage != null) {
              if (_aiFeedbackText != customMessage) {
                _aiFeedbackText = customMessage;
                updated = true;
                debugPrint('💬 [AI] Feedback (custom): $customMessage');
              }
            } else {
              // AI sends: {"severity": "...", "text": {"ar": "...", "en": "..."}}
              final textObj = feedbackInfo['text'];
              if (textObj is Map) {
                final arFeedback = textObj['ar'] as String?;
                if (arFeedback != null && arFeedback.isNotEmpty) {
                  _aiFeedbackText = arFeedback;
                  updated = true;
                  debugPrint('💬 [AI] Feedback: $arFeedback');
                }
              } else if (feedbackInfo.containsKey('ar')) {
                // Fallback: direct {"feedback": {"ar": "..."}}
                final arFeedback = feedbackInfo['ar'] as String?;
                if (arFeedback != null && arFeedback.isNotEmpty) {
                  _aiFeedbackText = arFeedback;
                  updated = true;
                  debugPrint('💬 [AI] Feedback (direct): $arFeedback');
                }
              }
            }
          }
        }

        // 1. Parse pose info if available
        bool foundLandmarks = false;
        if (data.containsKey('pose') && data['pose'] is Map) {
          final pose = data['pose'];
          _visibilityRatio = (pose['visibility_ratio'] as num?)?.toDouble() ?? 0.0;
          _bodyDetected = pose['detected'] == true;
          
          if (pose.containsKey('landmarks') && pose['landmarks'] is List) {
            _parseLandmarks(pose['landmarks']);
            foundLandmarks = true;
          } else if (pose.containsKey('keypoints') && pose['keypoints'] is List) {
            _parseLandmarks(pose['keypoints']);
            foundLandmarks = true;
          }
        }

        // 2. Fallback to root data for landmarks if not found in pose
        if (!foundLandmarks) {
          if (data.containsKey('landmarks') && data['landmarks'] is List) {
            _parseLandmarks(data['landmarks']);
            foundLandmarks = true;
          } else if (data.containsKey('keypoints') && data['keypoints'] is List) {
            _parseLandmarks(data['keypoints']);
            foundLandmarks = true;
          }
        }

        if (foundLandmarks) {
          updated = true;
          // _debugError = ''; // Commented out to see the parse debug info
        } else {
          // If we reach here, we didn't find any landmarks anywhere.
          // Let's print the keys of `data` to see what we actually received.
          _debugError = 'No landmarks found. Data keys: ${data.keys.join(", ")}';
        }
      }

      if (updated) setState(() {});
    } catch (e) {
      debugPrint('❌ [AI] Response parse error: $e — raw message: ${message.substring(0, message.length.clamp(0, 300))}');
    }
  }

  void _parseLandmarks(List dynamicList) {
    List<PoseLandmark> newLandmarks = [];
    _debugError = 'Len: ${dynamicList.length} | ';
    
    if (dynamicList.isNotEmpty) {
      final first = dynamicList[0];
      _debugError += 'Type: ${first.runtimeType} | Val: ${first.toString().length > 60 ? first.toString().substring(0, 60) : first.toString()}';
    }

    for (var item in dynamicList) {
      if (item is Map) {
        final x = (item['x'] as num?)?.toDouble();
        final y = (item['y'] as num?)?.toDouble();
        final confidence = (item['confidence'] as num?)?.toDouble() ?? 0.0;
        final visible = item['visible'] == true || item['visible'] == "true"; 
        if (x != null && y != null) {
          newLandmarks.add(PoseLandmark(
            x: x, 
            y: y, 
            confidence: confidence, 
            visible: visible,
          ));
        }
      } else if (item is List && item.length >= 2) {
        final x = (item[0] as num?)?.toDouble() ?? 0.0;
        final y = (item[1] as num?)?.toDouble() ?? 0.0;
        final confidence = item.length > 2 ? ((item[2] as num?)?.toDouble() ?? 0.0) : 0.0;
        newLandmarks.add(PoseLandmark(x: x, y: y, confidence: confidence, visible: true));
      }
    }
    _landmarks = newLandmarks;
  }

  void _handleSessionEnded(Map<String, dynamic> data) async {
    if (_isCompleting || _sessionDone) return;
    setState(() {
      _isCompleting = true;
      _sessionDone = true;
    });

    _stopwatch.stop();
    _timerUpdater?.cancel();
    _frameTimer?.cancel();
    try {
      _cameraController?.stopImageStream();
    } catch (_) {}
    _wsChannel?.sink.close();

    // AI session_ended format:
    // {"type": "session_ended", "summary": {"completed_reps": 10, "final_score": 91, ...}}
    // OR idle_timeout: {"type": "session_ended", "reason": "idle_timeout", "summary": {...}}
    final summary = (data['summary'] as Map<String, dynamic>?) ?? data;
    
    final finalScore = (summary['final_score'] as num?)?.toDouble() ?? 0.0;
    // Normalize score: AI sends 0-100, backend expects 0-1
    final normalizedScore = finalScore > 1 ? finalScore / 100.0 : finalScore;
    
    final finalFeedback = summary['final_feedback'];
    String feedbackText = 'Done!';
    if (finalFeedback is Map) {
      feedbackText = (finalFeedback['ar'] ?? finalFeedback['en'] ?? 'Done!').toString();
    } else if (finalFeedback is String) {
      feedbackText = finalFeedback;
    }
    
    int summaryReps = (summary['completed_reps'] as num?)?.toInt() ?? _completedReps;
    final totalRepsDone = summaryReps > _completedReps ? summaryReps : _completedReps;
    final reason = data['reason'] as String?;

    // Each rep is exactly 10% (10 reps = 100%)
    final calculatedScore = (totalRepsDone * 10).clamp(0, 100) / 100.0;
    final bestScore = normalizedScore > calculatedScore ? normalizedScore : calculatedScore;

    debugPrint('📊 [Session] Ended — reason: $reason, reps: $totalRepsDone, score: $normalizedScore, feedback: $feedbackText');

    try {
      // Forward the result to Main Backend (Laravel) using its internal int ID
      final completed = await ExerciseService.completeSession(
        sessionId: widget.laravelSessionId,
        completedReps: totalRepsDone,
        score: bestScore,
        feedback: feedbackText,
      );

      // Accumulate progress instead of overwriting
      final int newProgressPoints = totalRepsDone * 10;
      final int oldProgress = ProgressService.currentProgress.value?.bodyProgress ?? 0;
      final int cumulativeScore = (oldProgress + newProgressPoints).clamp(0, 100);

      // Also report to the Progress tracking API
      ProgressService.saveBodyTrainingScore(
        exerciseName: widget.exercise.displayName,
        score: cumulativeScore,
      );

      if (!mounted) return;
      _showResultDialog(completed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving result: $e')));
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  String _formatElapsed() {
    final s = _stopwatch.elapsed.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _initCamera() async {
    debugPrint('📷 [Camera] Requesting permission...');
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      debugPrint('❌ [Camera] Permission denied!');
      return;
    }
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('❌ [Camera] No cameras found!');
        return;
      }
      debugPrint('📷 [Camera] Found ${_cameras.length} cameras');

      // Select front camera by default
      _selectedCameraIdx = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front);
      if (_selectedCameraIdx == -1) _selectedCameraIdx = 0;

      await _setupCameraController(_cameras[_selectedCameraIdx]);
    } catch (e) {
      debugPrint('❌ [Camera] Init error: $e');
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    _cameraController = CameraController(
      camera, 
      ResolutionPreset.low, // Lowered to speed up manual YUV to JPEG conversion
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    
    await _cameraController!.initialize();
    
    // CRITICAL: Disable flash to prevent screen/LED flash
    try {
      await _cameraController!.setFlashMode(FlashMode.off);
    } catch (_) {}
    
    debugPrint('📷 [Camera] Initialized: ${camera.lensDirection}, flash: OFF');
    
    if (mounted) {
      setState(() => _cameraReady = true);
      
      // Use startImageStream for continuous frames (no flash, no precapture, no file I/O)
      _startFrameStreaming();
    }
  }

  int _frameSentCount = 0;
  int _frameSkipCounter = 0;
  static const int _frameSkipRate = 1; // Process every frame since we now resize and use low res

  void _startFrameStreaming() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    // Get sensor orientation for correct image rotation
    final sensorOrientation = _cameras[_selectedCameraIdx].sensorOrientation;
    final isFrontCamera = _cameras[_selectedCameraIdx].lensDirection == CameraLensDirection.front;
    
    debugPrint('📷 [Camera] Starting image stream... sensorOrientation=$sensorOrientation, isFront=$isFrontCamera');
    
    _cameraController!.startImageStream((CameraImage cameraImage) {
      // Skip frames to reduce load (camera gives ~30 FPS, we want ~10 FPS)
      _frameSkipCounter++;
      if (_frameSkipCounter % _frameSkipRate != 0) return;
      
      if (_wsChannel == null || _sessionDone) return;
      if (_isProcessingFrame) return;
      
      _isProcessingFrame = true;
      
      // Convert YUV420 → JPEG in background isolate
      _convertAndSendFrame(cameraImage, sensorOrientation, isFrontCamera);
    });
    
    debugPrint('📷 [Camera] Image stream started (every ${_frameSkipRate}rd frame)');
  }

  Future<void> _convertAndSendFrame(CameraImage cameraImage, int sensorOrientation, bool isFrontCamera) async {
    try {
      // Collect plane data for the isolate (CameraImage can't cross isolate boundaries)
      final int width = cameraImage.width;
      final int height = cameraImage.height;
      final Uint8List yPlane = Uint8List.fromList(cameraImage.planes[0].bytes);
      final Uint8List uPlane = Uint8List.fromList(cameraImage.planes[1].bytes);
      final Uint8List vPlane = Uint8List.fromList(cameraImage.planes[2].bytes);
      final int yRowStride = cameraImage.planes[0].bytesPerRow;
      final int uvRowStride = cameraImage.planes[1].bytesPerRow;
      final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

      // Convert in background isolate to avoid janking the UI
      final start = DateTime.now();
      final Uint8List? jpegBytes = await compute(_yuv420ToJpeg, {
        'width': width,
        'height': height,
        'yPlane': yPlane,
        'uPlane': uPlane,
        'vPlane': vPlane,
        'yRowStride': yRowStride,
        'uvRowStride': uvRowStride,
        'uvPixelStride': uvPixelStride,
        'rotation': sensorOrientation,
        'isFrontCamera': isFrontCamera,
      });
      final elapsed = DateTime.now().difference(start).inMilliseconds;

      if (jpegBytes != null && _wsChannel != null) {
        _wsChannel!.sink.add(jpegBytes);
        _frameSentCount++;
        _sentFrames++;
        
        final elapsedFps = DateTime.now().difference(_fpsStart).inSeconds;
        if (elapsedFps >= 1) {
          debugPrint('Actual FPS: $_sentFrames (Conversion took $elapsed ms)');
          _fpsStart = DateTime.now();
          _sentFrames = 0;
        }
        
        if (_frameSentCount <= 5 || _frameSentCount % 100 == 0) {
          debugPrint('📤 [Frame] #$_frameSentCount sent (${jpegBytes.length} bytes, ${width}x$height → rotated $sensorOrientation°). Conversion took $elapsed ms');
        }
      } else if (jpegBytes == null) {
        debugPrint('❌ [Frame] JPEG conversion returned null!');
      }
    } catch (e) {
      debugPrint('❌ [Frame] Convert/send error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  /// Runs in a background isolate — converts YUV420 camera data to JPEG bytes
  static Uint8List? _yuv420ToJpeg(Map<String, dynamic> params) {
    try {
      final int width = params['width'];
      final int height = params['height'];
      final Uint8List yPlane = params['yPlane'];
      final Uint8List uPlane = params['uPlane'];
      final Uint8List vPlane = params['vPlane'];
      final int yRowStride = params['yRowStride'];
      final int uvRowStride = params['uvRowStride'];
      final int uvPixelStride = params['uvPixelStride'];
      final int rotation = params['rotation'] ?? 0;
      final bool isFrontCamera = params['isFrontCamera'] ?? false;

      // Create an RGB image from YUV420 data
      final rawImage = img_lib.Image(width: width, height: height);
      
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * yRowStride + x;
          final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

          int yVal = yPlane[yIndex];
          int uVal = uPlane[uvIndex];
          int vVal = vPlane[uvIndex];

          // YUV → RGB conversion
          int r = (yVal + 1.370705 * (vVal - 128)).round().clamp(0, 255);
          int g = (yVal - 0.337633 * (uVal - 128) - 0.698001 * (vVal - 128)).round().clamp(0, 255);
          int b = (yVal + 1.732446 * (uVal - 128)).round().clamp(0, 255);

          rawImage.setPixelRgba(x, y, r, g, b, 255);
        }
      }

      // Rotate image to correct orientation
      // Android camera sensor is usually landscape, need rotation for portrait
      img_lib.Image orientedImage = rawImage;
      if (rotation != 0) {
        orientedImage = img_lib.copyRotate(rawImage, angle: rotation);
      }
      
      // For front camera, mirror horizontally so AI sees correct left/right
      if (isFrontCamera) {
        orientedImage = img_lib.flipHorizontal(orientedImage);
      }

      // Resize to reduce payload and speed up network transfer
      orientedImage = img_lib.copyResize(orientedImage, width: 320);

      // Encode to JPEG with 60% quality (instead of 85% to save bandwidth)
      return Uint8List.fromList(img_lib.encodeJpg(orientedImage, quality: 60));
    } catch (e) {
      return null;
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.isEmpty || _cameras.length == 1) return;
    
    // Stop current stream before switching
    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}
    
    setState(() => _cameraReady = false);
    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras.length;
    await _setupCameraController(_cameras[_selectedCameraIdx]);
  }

  @override
  void dispose() {
    debugPrint('⚠️ [Session] dispose() called! frameSent=$_frameSentCount');
    _timerUpdater?.cancel();
    _frameTimer?.cancel();
    _stopwatch.stop();
    try {
      _cameraController?.stopImageStream();
    } catch (_) {}
    _wsChannel?.sink.close();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _completeSession() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    _stopwatch.stop();
    _timerUpdater?.cancel();
    _frameTimer?.cancel();
    try {
      _cameraController?.stopImageStream();
    } catch (_) {}

    // Tell the AI server to end the session
    try {
      _wsChannel?.sink.add(jsonEncode({"type": "end_session"}));
    } catch (_) {}

    try {
      final totalReps = 10; // Force 10 reps target for consistent 10% per rep
      final ratio = (_completedReps / totalReps).clamp(0.0, 1.0);
      final score = double.parse(ratio.toStringAsFixed(2));
      final feedback = ratio >= 0.9
          ? 'Excellent! You are a star! ⭐'
          : ratio >= 0.6
              ? 'Great job! Keep it up! 💪'
              : 'Good try! Practice makes perfect! 🎯';

      // Complete the Laravel Session manually
      final completed = await ExerciseService.completeSession(
        sessionId: widget.laravelSessionId,
        completedReps: _completedReps,
        score: score,
        feedback: feedback,
      );

      // Accumulate progress instead of overwriting
      final int newProgressPoints = _completedReps * 10;
      final int oldProgress = ProgressService.currentProgress.value?.bodyProgress ?? 0;
      final int cumulativeScore = (oldProgress + newProgressPoints).clamp(0, 100);

      // Also report to the Progress tracking API
      ProgressService.saveBodyTrainingScore(
        exerciseName: widget.exercise.displayName,
        score: cumulativeScore,
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
    final finalReps = result.completedReps > _completedReps ? result.completedReps : _completedReps;
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
                  _ResultStat(emoji: '🔁', value: '$finalReps', label: 'Reps'),
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
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(_cameraController!),
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _LandmarkPainter(_landmarks),
                                    ),
                                  ),
                                  // Debug Visualization Info
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Visibility: ${(_visibilityRatio * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Body Detected: $_bodyDetected',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Points count: ${_landmarks.length}',
                                            style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Data: $_debugError',
                                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                                          ),
                                          if (_landmarks.isNotEmpty)
                                            ..._buildJointConfidences(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _buildCameraLoading(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            // AI Feedback Bar
            if (_aiFeedbackText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_aiFeedbackText),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _aiFeedbackText,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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

  List<Widget> _buildJointConfidences() {
    int lKneeIdx = -1;
    int rKneeIdx = -1;
    int lShoulderIdx = -1;

    if (_landmarks.length == 33) {
      lKneeIdx = 25;
      rKneeIdx = 26;
      lShoulderIdx = 11;
    } else if (_landmarks.length == 17) {
      lKneeIdx = 13;
      rKneeIdx = 14;
      lShoulderIdx = 5;
    } else if (_landmarks.length >= 27) {
      lKneeIdx = 25;
      rKneeIdx = 26;
      lShoulderIdx = 11;
    }

    if (lKneeIdx == -1 || lKneeIdx >= _landmarks.length) return [];

    Color getColor(double conf) {
      if (conf >= 0.8) return Colors.greenAccent;
      if (conf >= 0.5) return Colors.yellowAccent;
      return Colors.redAccent;
    }

    return [
      const SizedBox(height: 8),
      Text('LEFT_KNEE: ${_landmarks[lKneeIdx].confidence.toStringAsFixed(2)}', 
           style: TextStyle(color: getColor(_landmarks[lKneeIdx].confidence), fontWeight: FontWeight.bold)),
      Text('RIGHT_KNEE: ${_landmarks[rKneeIdx].confidence.toStringAsFixed(2)}', 
           style: TextStyle(color: getColor(_landmarks[rKneeIdx].confidence), fontWeight: FontWeight.bold)),
      Text('LEFT_SHOULDER: ${_landmarks[lShoulderIdx].confidence.toStringAsFixed(2)}', 
           style: TextStyle(color: getColor(_landmarks[lShoulderIdx].confidence), fontWeight: FontWeight.bold)),
    ];
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

class _LandmarkPainter extends CustomPainter {
  final List<PoseLandmark> landmarks;

  _LandmarkPainter(this.landmarks);

  @override
  void paint(Canvas canvas, Size size) {
    // TEST DOT: Draw a big blue dot in the center of the screen to prove CustomPaint is rendering
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 15, Paint()..color = Colors.blue.withValues(alpha: 0.5));

    if (landmarks.isEmpty) return;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw skeleton lines
    List<List<int>> connections = [];
    if (landmarks.length == 33) {
      // Blazepose
      connections = [
        [11, 13], [13, 15], // Left arm
        [12, 14], [14, 16], // Right arm
        [11, 12], // Shoulders
        [11, 23], [12, 24], // Torso
        [23, 24], // Hips
        [23, 25], [25, 27], // Left leg
        [24, 26], [26, 28], // Right leg
      ];
    } else if (landmarks.length == 17) {
      // YOLOv8
      connections = [
        [5, 7], [7, 9], // Left arm
        [6, 8], [8, 10], // Right arm
        [5, 6], // Shoulders
        [5, 11], [6, 12], // Torso
        [11, 12], // Hips
        [11, 13], [13, 15], // Left leg
        [12, 14], [14, 16], // Right leg
      ];
    }

    for (final connection in connections) {
      final p1Idx = connection[0];
      final p2Idx = connection[1];
      if (p1Idx < landmarks.length && p2Idx < landmarks.length) {
        final p1 = landmarks[p1Idx];
        final p2 = landmarks[p2Idx];
        if (p1.confidence > 0.1 && p2.confidence > 0.1) {
          double x1 = p1.x * size.width;
          double y1 = p1.y * size.height;
          double x2 = p2.x * size.width;
          double y2 = p2.y * size.height;
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        }
      }
    }

    // Draw joints
    for (final point in landmarks) {
      double px = point.x * size.width;
      double py = point.y * size.height;
      
      Color pointColor;
      if (point.confidence >= 0.8) {
        pointColor = Colors.green;
      } else if (point.confidence >= 0.5) {
        pointColor = Colors.yellow;
      } else {
        pointColor = Colors.red;
      }

      final paint = Paint()
        ..color = pointColor
        ..style = PaintingStyle.fill;
        
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(Offset(px, py), 6, paint);
      canvas.drawCircle(Offset(px, py), 6, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LandmarkPainter oldDelegate) {
    return true; // We want to repaint every time we get new landmarks
  }
}

class PoseLandmark {
  final double x;
  final double y;
  final double confidence;
  final bool visible;

  PoseLandmark({
    required this.x,
    required this.y,
    required this.confidence,
    required this.visible,
  });
}
