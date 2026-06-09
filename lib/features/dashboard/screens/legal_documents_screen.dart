import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/legal_docs.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

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
        itemCount: legalDocuments.length,
        separatorBuilder: (context, index) => Divider(
          color: theme.dividerColor.withOpacity(0.3),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final title = legalDocuments.keys.elementAt(index);
          final content = legalDocuments.values.elementAt(index);
          
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
                  builder: (_) => _DocumentViewerScreen(title: title, content: content),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DocumentViewerScreen extends StatelessWidget {
  final String title;
  final String content;

  const _DocumentViewerScreen({required this.title, required this.content});

  String _formatToMarkdown(String text) {
    // Basic heuristics to make legal texts look like markdown
    var lines = text.split('\n');
    var result = <String>[];
    for (var line in lines) {
      final t = line.trim();
      if (t.isEmpty) {
        result.add('');
        continue;
      }
      if (t.length < 50 && RegExp(r'^\d+\. ').hasMatch(t)) {
        result.add('### $t');
      } else if (t.length < 40 && !t.endsWith('.') && !t.contains(' ')) {
        result.add('**$t**');
      } else if (t.startsWith('Effective Date:') || t.startsWith('Last Updated:')) {
        result.add('*$t*');
      } else {
        result.add(t);
      }
    }
    return result.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markdownContent = _formatToMarkdown(content);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Markdown(
        data: markdownContent,
        padding: const EdgeInsets.all(24.0),
        styleSheet: MarkdownStyleSheet(
          h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          strong: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          em: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
      ),
    );
  }
}
