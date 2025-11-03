import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool scanned = false;
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!scanned) {
      setState(() => scanned = true);
      cameraController.stop();
      Navigator.pushReplacementNamed(context, '/child_info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Scan Bracelet QR',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: AppColors.primary),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: AppColors.primary),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: _onDetect,
                  ),
                ),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Positioned(
                  bottom: 30, // ✅ تقليل المسافة لتفادي overflow
                  child: Container(
                    width: constraints.maxWidth * 0.9,
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.4),
                    child: const Text(
                      'Align the QR code within the frame to scan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
