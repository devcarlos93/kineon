import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/custom_list_repository.dart';
import '../providers/custom_list_providers.dart';
import 'create_list_modal.dart'; // For stringToIcon
import 'list_limit_modal.dart';

/// Modal para añadir un item a una lista personalizada
class AddToListModal extends ConsumerStatefulWidget {
  final int tmdbId;
  final ContentType contentType;
  final String? title;
  final String? posterPath;

  const AddToListModal({
    super.key,
    required this.tmdbId,
    required this.contentType,
    this.title,
    this.posterPath,
  });

  static Future<void> show(
    BuildContext context, {
    required int tmdbId,
    required ContentType contentType,
    String? title,
    String? posterPath,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (ctx) => AddToListModal(
        tmdbId: tmdbId,
        contentType: contentType,
        title: title,
        posterPath: posterPath,
      ),
    );
  }

  @override
  ConsumerState<AddToListModal> createState() => _AddToListModalState();
}

class _AddToListModalState extends ConsumerState<AddToListModal> {
  Set<String> _selectedListIds = {};
  Set<String> _initialListIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final listsContaining = await ref.read(
      listsContainingItemProvider(ItemParams(
        tmdbId: widget.tmdbId,
        contentType: widget.contentType,
      )).future,
    );
    setState(() {
      _initialListIds = listsContaining.map((l) => l.id).toSet();
      _selectedListIds = Set.from(_initialListIds);
    });
  }

  Future<void> _saveChanges() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final actions = ref.read(customListActionsProvider.notifier);

    // Lists to add to
    final toAdd = _selectedListIds.difference(_initialListIds);
    // Lists to remove from
    final toRemove = _initialListIds.difference(_selectedListIds);

    // Verificar límites antes de añadir
    for (final listId in toAdd) {
      final limitCheck = await actions.canAddItemToList(listId);
      if (!limitCheck.allowed) {
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pop(context);
          ListLimitModal.show(
            context,
            reason: limitCheck.reason!,
            current: limitCheck.current,
            limit: limitCheck.limit,
          );
        }
        return;
      }
    }

    for (final listId in toAdd) {
      await actions.addItemToList(
        listId,
        widget.tmdbId,
        widget.contentType,
        posterPath: widget.posterPath,
      );
    }

    for (final listId in toRemove) {
      await actions.removeItemFromList(listId, widget.tmdbId, widget.contentType);
    }

    if (mounted) {
      Navigator.pop(context);
      // Show feedback
      if (toAdd.isNotEmpty || toRemove.isNotEmpty) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              toAdd.isNotEmpty ? 'Añadido a lista' : 'Eliminado de lista',
              style: TextStyle(color: colors.textOnAccent),
            ),
            backgroundColor: colors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showCreateListModal() {
    CreateListModal.show(
      context,
      onCreate: (name, icon) async {
        final list = await ref
            .read(customListActionsProvider.notifier)
            .createList(name, icon);
        if (list != null && mounted) {
          setState(() {
            _selectedListIds.add(list.id);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final listsAsync = ref.watch(customListsProvider);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
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
                  color: colors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Añadir a lista',
                          style: AppTypography.h3.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (widget.title != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.title!,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8),
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

              // Lists
              Flexible(
                child: listsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: CupertinoActivityIndicator(),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Error al cargar listas',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  data: (lists) {
                    if (lists.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildListSelector(lists);
                  },
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    // Create new list
                    Expanded(
                      child: GestureDetector(
                        onTap: _showCreateListModal,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.surfaceBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.plus,
                                color: colors.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Nueva lista',
                                style: AppTypography.labelMedium.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save button
                    Expanded(
                      child: GestureDetector(
                        onTap: _saveChanges,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CupertinoActivityIndicator(
                                    color: AppColors.textOnAccent,
                                  )
                                : Text(
                                    'Guardar',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.textOnAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.folder,
            size: 48,
            color: colors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes listas',
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crea una lista para organizar tu contenido',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListSelector(List<CustomList> lists) {
    final colors = context.colors;
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        final isSelected = _selectedListIds.contains(list.id);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedListIds.remove(list.id);
              } else {
                _selectedListIds.add(list.id);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.accent.withValues(alpha: 0.1)
                  : colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colors.accent.withValues(alpha: 0.3)
                    : colors.surfaceBorder,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    stringToIcon(list.icon),
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Name & count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        '${list.itemCount} items',
                        style: AppTypography.caption.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? colors.accent
                          : colors.textTertiary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: AppColors.textOnAccent,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
