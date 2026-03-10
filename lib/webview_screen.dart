import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isUrlInvalid = false;

  @override
  void initState() {
    super.initState();

    final Uri? uri = Uri.tryParse(widget.url);

    if (uri == null) {
      _isUrlInvalid = true;
      _isLoading = false;
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;
            setState(() {
              _isUrlInvalid = true;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('taskView'.tr())),
      body: Stack(
        children: [
          if (!_isUrlInvalid) WebViewWidget(controller: _controller),

          if (_isUrlInvalid)
            Center(
              child: Text(
                'urlNotAvailable'.tr(),
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
