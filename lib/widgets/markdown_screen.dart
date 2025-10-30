import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MarkdownScreen extends StatefulWidget {
  final String title;
  final String assetPath;

  const MarkdownScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<MarkdownScreen> createState() => _MarkdownScreenState();
}

class _MarkdownScreenState extends State<MarkdownScreen> {
  String _markdownData = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Test dengan data hardcoded dulu
    _isLoading = false;
    _loadMarkdown(); // comment sementara
  }

  Future<void> _loadMarkdown() async {
    try {
      if (kDebugMode) {
        debugPrint('✅ Loading markdown from: ${widget.assetPath}');
      }
      final data = await rootBundle.loadString(widget.assetPath);
      if (kDebugMode) {
        debugPrint('✅ Markdown loaded successfully: ${data.length} characters');
      }

      if (mounted) {
        setState(() {
          _markdownData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading markdown: $e');
      }
      if (mounted) {
        setState(() {
          _markdownData =
              '# Error\nTidak dapat memuat file Markdown.\n\nError: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat konten...'),
                ],
              ),
            )
          : Markdown(
              data: _markdownData,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    p: const TextStyle(fontSize: 16, height: 1.5),
                    h1: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    h2: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    h3: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    blockquotePadding: const EdgeInsets.all(16),
                    code: TextStyle(
                      backgroundColor: Colors.grey[200],
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    codeblockPadding: const EdgeInsets.all(12),
                  ),
            ),
    );
  }
}
