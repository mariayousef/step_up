import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class VideoCacheService {
  static final Dio _dio = Dio();
  // Keep track of downloads to avoid duplicate simultaneous downloads
  static final Map<String, Future<File?>> _activeDownloads = {};

  /// Prefetches a video and caches it locally
  static Future<File?> prefetchVideo(String url) async {
    // Force HTTPS to prevent ngrok redirects that strip custom headers
    String secureUrl = url.startsWith('http://') 
        ? url.replaceFirst('http://', 'https://') 
        : url;
        
    final encodedUrl = secureUrl.replaceAll(' ', '%20');
    
    // Check if already downloading
    if (_activeDownloads.containsKey(encodedUrl)) {
      return _activeDownloads[encodedUrl];
    }

    final future = _downloadVideo(encodedUrl);
    _activeDownloads[encodedUrl] = future;
    
    final result = await future;
    _activeDownloads.remove(encodedUrl);
    return result;
  }

  static Future<File?> _downloadVideo(String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = url.hashCode.toString() + '.mp4';
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        // Check if it's a valid video file (> 20KB)
        // This prevents caching HTML error pages from ngrok
        if (await file.length() > 20000) {
          return file;
        } else {
          await file.delete(); // Delete corrupted/invalid cache
        }
      }

      // Download
      await _dio.download(
        url,
        file.path,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'ngrok-skip-browser-warning': 'true',
            'Accept': '*/*',
          },
        ),
      );

      // Verify downloaded file size
      if (await file.exists() && await file.length() < 20000) {
        await file.delete();
        throw Exception("Downloaded file is too small, likely an error page.");
      }

      return file;
    } catch (e) {
      print('VideoCacheService: Error caching video: $e');
      return null;
    }
  }

  /// Gets the cached file if it exists, otherwise returns null
  static Future<File?> getCachedVideoFile(String url) async {
    try {
      String secureUrl = url.startsWith('http://') 
          ? url.replaceFirst('http://', 'https://') 
          : url;
      final encodedUrl = secureUrl.replaceAll(' ', '%20');
      
      final dir = await getTemporaryDirectory();
      final fileName = encodedUrl.hashCode.toString() + '.mp4';
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
