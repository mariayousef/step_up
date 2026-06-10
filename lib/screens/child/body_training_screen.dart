import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:step_up/services/body_training_service.dart';
import 'package:step_up/utils/camera_image_converter.dart';

class BodyTrainingScreen extends StatefulWidget {
  const BodyTrainingScreen({Key? key}) : super(key: key);

  @override
  State<BodyTrainingScreen> createState() => _BodyTrainingScreenState();
}

class _BodyTrainingScreenState extends State<BodyTrainingScreen> {
  // Update these for your local testing
  final String _baseUrl = 'https://roundup-camera-unsteady.ngrok-free.dev';
  final String _apiKey = 'zqMjzbY59LGYgCYUwI03d5cHgsade62pYw8WemyTxJM';
  final String _userId = 'child_001';
  CameraController? _cameraController;
  late BodyTrainingService _aiService;
  
  bool _isSessionActive = false;
  bool _isProcessingFrame = false;
  String _currentExercise = 'squat';
  String _debugStatus = 'Ready';
  
  Map<String, dynamic>? _lastFrameResult;
  DateTime? _lastFrameTime;
  
  // Target FPS: 10
  final int _targetFrameIntervalMs = 100;

  @override
  void initState() {
    super.initState();
    _initAIService();
    _initCamera();
  }

  void _initAIService() {
    _aiService = BodyTrainingService(
      baseUrl: _baseUrl,
      apiKey: _apiKey,
    );

    _aiService.resultStream.listen((result) {
      if (mounted) {
        setState(() {
          final type = result['type'];
          if (type == 'error' || type == 'closed') {
            _debugStatus = 'WS $type: ${result['message']}';
          } else if (type == 'connected') {
            _debugStatus = 'WS Connected! Ready for frames.';
          } else if (type == 'session_ended') {
            _debugStatus = 'Session Ended by Server.';
            _lastFrameResult = null;
          } else if (type == 'frame_result') {
            _lastFrameResult = result;
          }
        });
      }
    });
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Medium usually maps to 480p or 720p
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _startSession() async {
    setState(() {
      _isSessionActive = true;
      _debugStatus = 'Starting session...';
    });

    final sessionId = await _aiService.startSession(_userId, 'en');
    if (sessionId != null) {
      setState(() {
        _debugStatus = 'Session ID: $sessionId\nConnecting WebSocket...';
      });
      _aiService.connectWebSocket(sessionId);
      _startFrameProcessing();
    } else {
      // Handle error
      setState(() {
        _isSessionActive = false;
        _debugStatus = 'Failed to start AI session';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start AI session')),
      );
    }
  }

  void _startFrameProcessing() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isSessionActive || _isProcessingFrame) return;

      final now = DateTime.now();
      if (_lastFrameTime != null) {
        final diff = now.difference(_lastFrameTime!).inMilliseconds;
        if (diff < _targetFrameIntervalMs) {
          // Throttle frames to target FPS
          return;
        }
      }

      _lastFrameTime = now;
      _isProcessingFrame = true;

      try {
        final jpegBytes = await CameraImageConverter.convertCameraImageToJpeg(image);
        if (jpegBytes != null && _isSessionActive) {
          _aiService.sendFrameAsBinary(Uint8List.fromList(jpegBytes));
          if (mounted) {
            setState(() {
              _debugStatus = 'Sending frames... Size: ${jpegBytes.length} bytes';
            });
          }
        } else if (jpegBytes == null) {
          if (mounted) {
            setState(() {
              _debugStatus = 'Frame conversion failed!';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _debugStatus = 'Error processing frame: $e';
          });
        }
        print('Error processing frame: $e');
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  Future<void> _endSession() async {
    setState(() {
      _isSessionActive = false;
      _lastFrameResult = null;
    });
    
    if (_cameraController?.value.isStreamingImages == true) {
      await _cameraController?.stopImageStream();
    }
    
    final summary = await _aiService.endSession();
    if (mounted && summary != null) {
      _showSessionSummary(summary);
    }
  }

  void _showSessionSummary(Map<String, dynamic> summary) {
    showDialog(
      context: context,
      builder: (context) {
        final results = summary['results'] as List<dynamic>? ?? [];
        final duration = summary['duration_seconds'] ?? 0;
        final minutes = duration ~/ 60;
        final seconds = duration % 60;
        final timeString = '${minutes}m ${seconds}s';
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉 Session Complete! 🎉', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.deepPurple)),
                const SizedBox(height: 8),
                Text('Duration: $timeString', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (results.isEmpty)
                          const Text('No exercises recorded.', style: TextStyle(fontSize: 16, color: Colors.black54))
                        else
                          ...results.map((r) {
                            final exercise = (r['exercise'] ?? '').toString().toUpperCase().replaceAll('_', ' ');
                            final correct = r['correct_reps'] ?? 0;
                            final incorrect = r['incorrect_reps'] ?? 0;
                            final abandoned = r['abandoned_attempts'] ?? 0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                                border: Border.all(color: Colors.purple.shade100, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('💪 ', style: TextStyle(fontSize: 20)),
                                      Expanded(child: Text(exercise, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.deepOrange))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildSummaryStat(Icons.check_circle, Colors.green, correct.toString(), 'Correct'),
                                      _buildSummaryStat(Icons.cancel, Colors.redAccent, incorrect.toString(), 'Incorrect'),
                                      _buildSummaryStat(Icons.warning_amber_rounded, Colors.orangeAccent, abandoned.toString(), 'Dropped'),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    elevation: 5,
                  ),
                  child: const Text('Awesome!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStat(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
      ],
    );
  }

  @override
  void dispose() {
    _endSession();
    _cameraController?.dispose();
    _aiService.dispose();
    super.dispose();
  }

  void _changeExercise(String newExercise) {
    if (newExercise != _currentExercise) {
      setState(() {
        _currentExercise = newExercise;
        _lastFrameResult = null; // Clear previous feedback
      });
      if (_isSessionActive) {
        _aiService.sendReset();
      }
    }
  }

  Widget _buildExerciseSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentExercise,
          dropdownColor: Colors.orangeAccent.shade200,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.white, size: 28),
          isExpanded: true,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _changeExercise(newValue);
            }
          },
          items: <String>[
            'squat',
            'lunges',
            'pullup',
            'jumping_jack',
            'punch',
            'wall_pushup'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.toUpperCase().replaceAll('_', ' '),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    final exercise = _lastFrameResult?['exercise']?['name'] ?? _currentExercise;
    final reps = _lastFrameResult?['reps']?['total'] ?? 0;
    final feedbackText = _lastFrameResult?['feedback']?['text']?['en'] ?? 'Waiting for movement...';
    final stabilityScore = _lastFrameResult?['stability_score']?.toDouble() ?? 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Reps',
                value: reps.toString(),
                color: Colors.purpleAccent,
                emoji: '🎯',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Exercise',
                value: exercise.toUpperCase().replaceAll('_', '\n'),
                color: Colors.deepOrange,
                emoji: '💪',
                valueSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Balance', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${(stabilityScore * 100).toStringAsFixed(0)}%', 
                    style: const TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: stabilityScore,
                  backgroundColor: Colors.grey.shade200,
                  color: stabilityScore > 0.7 ? Colors.greenAccent.shade400 : (stabilityScore > 0.4 ? Colors.orangeAccent : Colors.redAccent),
                  minHeight: 16,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feedbackText,
                        style: TextStyle(color: Colors.orange.shade900, fontSize: 20, fontWeight: FontWeight.w900, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required Color color, required String emoji, double valueSize = 36}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: valueSize, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: ElevatedButton.icon(
        onPressed: _startSession,
        icon: const Text('🚀', style: TextStyle(fontSize: 28)),
        label: const Text('Let\'s Start!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.green.shade500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          shadowColor: Colors.green.shade200,
        ),
      ),
    );
  }

  Widget _buildDebugStatus() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _debugStatus,
          style: const TextStyle(color: Colors.black87, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Training Time! 🤸‍♂️', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.deepPurple, fontSize: 26)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.deepPurple, size: 28),
        actions: [
          if (_isSessionActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.stop_circle, color: Colors.redAccent, size: 36),
                onPressed: _endSession,
              ),
            )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Camera Window
                  Center(
                    child: Container(
                      height: 280,
                      width: 210, // 3:4 ratio approx
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 6),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ]
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: _cameraController != null && _cameraController!.value.isInitialized
                            ? CameraPreview(_cameraController!)
                            : const Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Exercise Selector
                  _buildExerciseSelector(),
                  const SizedBox(height: 24),
                  
                  // Stats and Feedback
                  if (_isSessionActive) _buildFeedbackOverlay()
                  else _buildStartButton(),
                  
                  // Debug
                  if (_isSessionActive) _buildDebugStatus(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
