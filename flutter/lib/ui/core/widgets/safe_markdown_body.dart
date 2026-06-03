import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

class SafeMarkdownBody extends StatelessWidget {
  const SafeMarkdownBody({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final isChinese = locale.languageCode == 'zh';

    return MarkdownBody(
      data: sanitizeReadingMarkdown(data),
      inlineSyntaxes: [_AdjacentStrongEmphasisSyntax()],
      selectable: false,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        h1: isChinese
            ? theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'ChenYuluoyan',
                fontWeight: FontWeight.w400,
              )
            : theme.textTheme.headlineSmall,
        h2: isChinese
            ? theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'ChenYuluoyan',
                fontWeight: FontWeight.w400,
              )
            : theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        h3: isChinese
            ? theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'ChenYuluoyan',
                fontWeight: FontWeight.w400,
              )
            : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        p: theme.textTheme.bodyMedium,
        strong: isChinese
            ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)
            : null,
        blockquoteDecoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: theme.colorScheme.secondary, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.all(12),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
      ),
      imageBuilder: (uri, title, alt) => const SizedBox.shrink(),
    );
  }
}

class _AdjacentStrongEmphasisSyntax extends md.InlineSyntax {
  _AdjacentStrongEmphasisSyntax()
    : super(r'\*\*([^*\n]+?)\*\*', startCharacter: 0x2A);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('strong', match[1]!));
    return true;
  }
}

String sanitizeReadingMarkdown(String source) {
  final output = <String>[];
  var insideCodeBlock = false;

  for (final line in source.split('\n')) {
    final trimmed = line.trim();

    if (trimmed.startsWith('```')) {
      insideCodeBlock = !insideCodeBlock;
      continue;
    }

    if (insideCodeBlock) {
      continue;
    }

    if (_isForbiddenLine(trimmed)) {
      continue;
    }

    output.add(_normalizeSupportedEscapes(line));
  }

  return output.join('\n').trim();
}

String _normalizeSupportedEscapes(String line) {
  return line.replaceAll(r'\*', '*').replaceAll(r'\_', '_').replaceAllMapped(
    RegExp(r'\*\*\s*([^*\n]*?\S)\s*\*\*'),
    (match) {
      return '**${match[1]}**';
    },
  );
}

bool _isForbiddenLine(String line) {
  if (line.isEmpty) {
    return false;
  }

  if (RegExp(r'<\/?[a-zA-Z][^>]*>').hasMatch(line)) {
    return true;
  }

  if (RegExp(r'!\[[^\]]*]\([^)]*\)').hasMatch(line)) {
    return true;
  }

  if (RegExp(r'\[[^\]]+]\([^)]*\)').hasMatch(line)) {
    return true;
  }

  if (_looksLikeMarkdownTable(line) || _looksLikeMarkdownTableDivider(line)) {
    return true;
  }

  return false;
}

bool _looksLikeMarkdownTable(String line) {
  return '|'.allMatches(line).length >= 2;
}

bool _looksLikeMarkdownTableDivider(String line) {
  return RegExp(r'^\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+$').hasMatch(line);
}
