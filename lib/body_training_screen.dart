import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_colors.dart';

class BodyTrainingScreen extends StatefulWidget {
  const BodyTrainingScreen({super.key});

  @override
  State<BodyTrainingScreen> createState() => _BodyTrainingScreenState();
}

class _BodyTrainingScreenState extends State<BodyTrainingScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isCameraAvailable = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    // نطلب صلاحية الكاميرا
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _isCameraAvailable = false);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _isCameraAvailable = false);
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;

      if (!mounted) return;
      setState(() {
        _isCameraAvailable = true;
      });
    } catch (e) {
      debugPrint('Camera error: $e');
      setState(() => _isCameraAvailable = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _startExercise() {
    // هنا تضيفي لوجيك التمرين بعدين
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exercise started (camera is on)!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4FFF7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Body Training',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Row(
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0FFFB),
              Color(0xFFB9F3FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // الكارت الأبيض اللي فوق
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: const [
                    Text(
                      '🙌',
                      style: TextStyle(fontSize: 46),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Arms Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Raise your arms high!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // هنا بقى الكاميرا بدل البلاسيهولدر
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _isCameraAvailable && _initializeControllerFuture != null
                      ? FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return CameraPreview(_cameraController!);
                      } else {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                    },
                  )
                      : Container(
                    color: const Color(0xFF111827),
                    child: const Center(
                      child: Text(
                        'Camera not available',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _startExercise,
                  icon:
                  const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: const Text(
                    'Start Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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
