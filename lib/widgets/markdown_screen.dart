import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:markdown_widget/markdown_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    try {
      debugPrint('✅ Loading markdown from: ${widget.assetPath}');
      final data = await rootBundle.loadString(widget.assetPath);
      debugPrint('✅ Markdown loaded successfully: ${data.length} characters');
      if (mounted) {
        setState(() {
          _markdownData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _markdownData = '# Error\nTidak dapat memuat file Markdown.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Tema markdown otomatis menyesuaikan dark/light mode
    final config = MarkdownConfig(
      configs: [
        PConfig(
          textStyle: TextStyle(
            fontSize: 16,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
            height: 1.6,
          ),
        ),
        H1Config(
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        H2Config(
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        H3Config(
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        CodeConfig(
          style: TextStyle(
            backgroundColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _markdownData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: MarkdownBlock(data: _markdownData, config: config),
              ),
            ),
    );
  }
}
