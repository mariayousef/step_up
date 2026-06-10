import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() => _isCameraAvailable = false);
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() => _isCameraAvailable = false);
        return;
      }

      await _setupController();
    } catch (error) {
      debugPrint('Camera error: $error');
      if (!mounted) return;
      setState(() => _isCameraAvailable = false);
    }
  }

  Future<void> _setupController() async {
    // Dispose the old controller before initializing a new one
    // to prevent "camera in use" exceptions on Android/iOS.
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
    
    final controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.medium,
    );

    _cameraController = controller;
    _initializeControllerFuture = controller.initialize();
    
    try {
      await _initializeControllerFuture;
      if (!mounted) return;
      setState(() => _isCameraAvailable = true);
    } catch (error) {
      debugPrint('Camera switch error: $error');
      if (!mounted) return;
      setState(() => _isCameraAvailable = false);
    }
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;
    
    setState(() {
      _isCameraAvailable = false;
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    });
    
    await _setupController();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _startExercise() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exercise started (camera is on)!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4FFF7),
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0FFFB), Color(0xFFB9F3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildExerciseCard(),
              const SizedBox(height: 24),
              Expanded(child: _buildCameraPreview()),
              const SizedBox(height: 24),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Body Training',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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

  Widget _buildExerciseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
      child: const Column(
        children: [
          Icon(
            Icons.accessibility_new_rounded,
            color: AppColors.primary,
            size: 46,
          ),
          SizedBox(height: 12),
          Text(
            'Arms Up',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Raise your arms high!',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _initializeControllerFuture != null
              ? FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        _cameraController != null && _isCameraAvailable) {
                      return CameraPreview(_cameraController!);
                    }

                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  },
                )
              : Container(
                  color: const Color(0xFF111827),
                  alignment: Alignment.center,
                  child: const Text(
                    'Camera not available',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
          if (_cameras.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _switchCamera,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
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
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        label: const Text(
          'Start Exercise',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
