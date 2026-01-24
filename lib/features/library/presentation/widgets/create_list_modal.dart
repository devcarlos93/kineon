import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Available icons for custom lists
const List<IconData> availableListIcons = [
  CupertinoIcons.film,           // Clapperboard/movie
  CupertinoIcons.ticket,         // Ticket
  CupertinoIcons.star,           // Star
  CupertinoIcons.heart,          // Heart
  CupertinoIcons.flame,          // Fire
  Icons.diamond_outlined,        // Diamond
  CupertinoIcons.rocket,         // Rocket
  CupertinoIcons.moon_stars,     // Planet/moon
  CupertinoIcons.gamecontroller, // Gamepad
  CupertinoIcons.tv,             // TV
  CupertinoIcons.music_note,     // Music
  CupertinoIcons.book,           // Book
];

/// Map icon to string for storage
String iconToString(IconData icon) {
  final index = availableListIcons.indexOf(icon);
  return index >= 0 ? 'icon_$index' : 'icon_0';
}

/// Map string to icon for display
IconData stringToIcon(String? iconStr) {
  if (iconStr == null || !iconStr.startsWith('icon_')) {
    return availableListIcons[0];
  }
  final index = int.tryParse(iconStr.replaceFirst('icon_', '')) ?? 0;
  if (index >= 0 && index < availableListIcons.length) {
    return availableListIcons[index];
  }
  return availableListIcons[0];
}

/// Modal para crear una nueva lista
class CreateListModal extends StatefulWidget {
  final Function(String name, String icon) onCreate;

  const CreateListModal({
    super.key,
    required this.onCreate,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String name, String icon) onCreate,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CreateListModal(onCreate: onCreate),
    );
  }

  @override
  State<CreateListModal> createState() => _CreateListModalState();
}

class _CreateListModalState extends State<CreateListModal> {
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = availableListIcons[0];
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _nameController.text.trim().isNotEmpty;
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
    }
  }

  void _handleCreate() {
    if (!_isValid) return;
    HapticFeedback.mediumImpact();
    widget.onCreate(_nameController.text.trim(), iconToString(_selectedIcon));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textTertiary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.strings.libraryCreateList,
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: colors.textSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Icon selector section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.strings.libraryChooseIcon.toUpperCase(),
                      style: AppTypography.overline.copyWith(
                        color: colors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _IconGrid(
                      selectedIcon: _selectedIcon,
                      onIconSelected: (icon) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedIcon = icon);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Name input section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.strings.libraryListName.toUpperCase(),
                      style: AppTypography.overline.copyWith(
                        color: colors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.surfaceBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Selected icon preview
                          Container(
                            width: 52,
                            height: 52,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _selectedIcon,
                              color: colors.accent,
                              size: 24,
                            ),
                          ),
                          // Text field
                          Expanded(
                            child: CupertinoTextField(
                              controller: _nameController,
                              placeholder: l10n.strings.libraryListNameHint,
                              placeholderStyle: AppTypography.bodyMedium.copyWith(
                                color: colors.textTertiary,
                              ),
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                              decoration: const BoxDecoration(
                                color: CupertinoColors.transparent,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Create button with gradient
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: GestureDetector(
                  onTap: _isValid ? _handleCreate : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _isValid
                          ? LinearGradient(
                              colors: [
                                colors.accent,
                                const Color(0xFFA78BFA), // Purple accent
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: _isValid ? null : colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: _isValid
                          ? null
                          : Border.all(color: colors.surfaceBorder),
                    ),
                    child: Center(
                      child: Text(
                        l10n.strings.libraryCreate,
                        style: AppTypography.labelLarge.copyWith(
                          color: _isValid
                              ? AppColors.textOnAccent
                              : colors.textTertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid de iconos seleccionables - 6 columnas
class _IconGrid extends StatelessWidget {
  final IconData selectedIcon;
  final ValueChanged<IconData> onIconSelected;

  const _IconGrid({
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: availableListIcons.length,
      itemBuilder: (context, index) {
        final icon = availableListIcons[index];
        final isSelected = icon == selectedIcon;

        return GestureDetector(
          onTap: () => onIconSelected(icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.accent.withValues(alpha: 0.1)
                  : colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? colors.accent
                    : colors.surfaceBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? colors.accent : colors.textTertiary,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
