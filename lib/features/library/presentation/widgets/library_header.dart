import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Header de la pantalla de biblioteca
class LibraryHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final String? userName;

  const LibraryHeader({
    super.key,
    this.onSearchTap,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 8,
        20,
        16,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accent.withValues(alpha: 0.3),
                  colors.accentPurple.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              color: colors.accent,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              l10n.strings.libraryTitle,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Search button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSearchTap?.call();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: Icon(
                CupertinoIcons.search,
                color: colors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de búsqueda expandida
class LibrarySearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClose;
  final ValueChanged<String>? onChanged;

  const LibrarySearchBar({
    super.key,
    required this.controller,
    required this.onClose,
    this.onChanged,
  });

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 8,
        20,
        16,
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    CupertinoIcons.search,
                    color: colors.textTertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CupertinoTextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      placeholder: l10n.strings.librarySearchHint,
                      placeholderStyle: AppTypography.bodyMedium.copyWith(
                        color: colors.textTertiary,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      decoration: const BoxDecoration(
                        color: CupertinoColors.transparent,
                      ),
                      padding: EdgeInsets.zero,
                      onChanged: widget.onChanged,
                    ),
                  ),
                  if (widget.controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        widget.controller.clear();
                        widget.onChanged?.call('');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          CupertinoIcons.clear_circled_solid,
                          color: colors.textTertiary,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Cancel button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.controller.clear();
              widget.onClose();
            },
            child: Text(
              l10n.strings.libraryCancel,
              style: AppTypography.labelMedium.copyWith(
                color: colors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
