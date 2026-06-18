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
      // Added _v2 to filename to ignore previously corrupted partial downloads
      final fileName = url.hashCode.toString() + '_v2.mp4';
      final file = File('${dir.path}/$fileName');
      final tmpFile = File('${dir.path}/$fileName.tmp');

      if (await file.exists()) {
        if (await file.length() > 20000) {
          return file;
        } else {
          await file.delete(); 
        }
      }

      // Download to a temporary file first (atomic download)
      await _dio.download(
        url,
        tmpFile.path,
        options: Options(
          receiveTimeout: const Duration(minutes: 5), // Increased timeout for large videos
          sendTimeout: const Duration(minutes: 5),
          headers: {
            'ngrok-skip-browser-warning': 'true',
            'Accept': '*/*',
          },
        ),
      );

      // Verify downloaded tmp file size
      if (await tmpFile.exists()) {
        if (await tmpFile.length() < 20000) {
          await tmpFile.delete();
          throw Exception("Downloaded file is too small, likely an error page.");
        }
        // Rename tmp to final file only if download succeeds completely
        await tmpFile.rename(file.path);
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
      final fileName = encodedUrl.hashCode.toString() + '_v2.mp4';
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
