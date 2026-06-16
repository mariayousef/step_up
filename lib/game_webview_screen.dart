import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class GameWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const GameWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<GameWebViewScreen> createState() => _GameWebViewScreenState();
}

class _GameWebViewScreenState extends State<GameWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    _controller = controller;

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress > 50) {
              _injectAutoClicker();
            }
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);
            _injectAutoClicker();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebResourceError: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (_controller.platform is AndroidWebViewController) {
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  Future<void> _injectAutoClicker() async {
    try {
      await _controller.runJavaScript('''
        (function(){
          if (window.hasAutoClicker) return;
          window.hasAutoClicker = true;

          function autoClickContinue(doc) {
            if (!doc) doc = document;
            
            // Search in current document
            var elements = doc.querySelectorAll('a, button, span, div, p');
            for (var i = 0; i < elements.length; i++) {
              var el = elements[i];
              var text = (el.innerText || el.textContent || '').trim();
              if (/continue/i.test(text) && /browser/i.test(text)) {
                el.click();
                var events = ['mousedown', 'mouseup', 'click'];
                events.forEach(function(name) {
                  try {
                    el.dispatchEvent(new MouseEvent(name, { 
                      bubbles: true, 
                      cancelable: true, 
                      view: doc.defaultView || window 
                    }));
                  } catch (e) {}
                });
              }
            }
            
            // Search inside same-origin iframes recursively
            var iframes = doc.querySelectorAll('iframe');
            for (var j = 0; j < iframes.length; j++) {
              try {
                var iframeDoc = iframes[j].contentDocument || iframes[j].contentWindow.document;
                if (iframeDoc) {
                  autoClickContinue(iframeDoc);
                }
              } catch (e) {
                // Ignore cross-origin error
              }
            }
          }

          // Run immediately and periodically
          autoClickContinue();
          setInterval(autoClickContinue, 500);
        })();
      ''');
    } catch (e) {
      // ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9800)),
              ),
          ],
        ),
      ),
    );
  }
}
