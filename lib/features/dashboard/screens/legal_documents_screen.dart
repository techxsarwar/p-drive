import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  final Map<String, String> _documents = const {
    'Terms of Service': 'assets/legal/terms_of_service.txt',
    'Privacy Policy': 'assets/legal/privacy_policy.txt',
    'Acceptable Use Policy': 'assets/legal/acceptable_use_policy.txt',
    'Data Retention Policy': 'assets/legal/data_retention_policy.txt',
    'Security Policy': 'assets/legal/security_policy.txt',
    'Refund & Subscription Policy': 'assets/legal/refund_&_subscription_policy.txt',
    'Disclaimer': 'assets/legal/disclaimer.txt',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Legal & Policies',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: _documents.length,
        separatorBuilder: (context, index) => Divider(
          color: theme.dividerColor.withOpacity(0.3),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final title = _documents.keys.elementAt(index);
          final path = _documents.values.elementAt(index);
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.file_text, color: theme.colorScheme.primary, size: 20),
            ),
            title: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(LucideIcons.chevron_right, size: 20, color: theme.dividerColor),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _DocumentViewerScreen(title: title, filePath: path),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DocumentViewerScreen extends StatefulWidget {
  final String title;
  final String filePath;

  const _DocumentViewerScreen({required this.title, required this.filePath});

  @override
  State<_DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<_DocumentViewerScreen> {
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final text = await rootBundle.loadString(widget.filePath);
      setState(() {
        _content = text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Error loading document: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _content,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
    );
  }
}
