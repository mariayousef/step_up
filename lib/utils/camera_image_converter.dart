import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class CameraImageConverter {
  static Future<List<int>?> convertCameraImageToJpeg(CameraImage image) async {
    // Extract planes before sending to isolate to prevent SendPort exceptions
    final formatGroup = image.format.group;
    final width = image.width;
    final height = image.height;
    // IMPORTANT: Make a hard copy of the bytes! 
    // Camera plugin uses native memory buffers that are freed/reused immediately.
    // If we pass the raw pointer to an Isolate, it will crash the Android Camera2 API.
    final planes = image.planes.map((plane) => {
      'bytes': Uint8List.fromList(plane.bytes), 
      'bytesPerRow': plane.bytesPerRow,
      'bytesPerPixel': plane.bytesPerPixel,
    }).toList();

    return await Isolate.run(() => _convertImage(formatGroup, width, height, planes));
  }

  static List<int>? _convertImage(ImageFormatGroup formatGroup, int width, int height, List<Map<String, dynamic>> planes) {
    try {
      img.Image? convertedImage;
      if (formatGroup == ImageFormatGroup.yuv420) {
        convertedImage = _convertYUV420(width, height, planes);
      } else if (formatGroup == ImageFormatGroup.bgra8888) {
        convertedImage = _convertBGRA8888(width, height, planes);
      } else if (formatGroup == ImageFormatGroup.jpeg) {
        return planes[0]['bytes'] as Uint8List;
      }

      if (convertedImage != null) {
        // Resize to 640x480 as required
        final resized = img.copyResize(convertedImage, width: 640, height: 480);
        return img.encodeJpg(resized, quality: 80);
      }
    } catch (e) {
      print("Error converting image: $e");
    }
    return null;
  }

  static img.Image _convertBGRA8888(int width, int height, List<Map<String, dynamic>> planes) {
    final bytes = planes[0]['bytes'] as Uint8List;
    return img.Image.fromBytes(
      width: width,
      height: height,
      bytes: bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  static img.Image _convertYUV420(int width, int height, List<Map<String, dynamic>> planes) {
    final int uvRowStride = planes[1]['bytesPerRow'] as int;
    final int uvPixelStride = planes[1]['bytesPerPixel'] as int? ?? 1;

    final img.Image imgObj = img.Image(width: width, height: height);
    final Uint8List yPlane = planes[0]['bytes'] as Uint8List;
    final Uint8List uPlane = planes[1]['bytes'] as Uint8List;
    final Uint8List vPlane = planes[2]['bytes'] as Uint8List;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int index = y * width + x;

        final yp = yPlane[index];
        final up = uPlane[uvIndex];
        final vp = vPlane[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        imgObj.setPixelRgb(x, y, r, g, b);
      }
    }
    return imgObj;
  }
}
