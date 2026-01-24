import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Sección de configuración de notificaciones
class NotificationsSection extends ConsumerWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Notificaciones',
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Main toggle
          _NotificationToggle(
            icon: CupertinoIcons.bell,
            title: 'Activar notificaciones',
            subtitle: 'Recibe recomendaciones personalizadas',
            value: prefs.enabled,
            onChanged: (value) => notifier.setEnabled(value),
          ),

          // Show additional options only if enabled
          if (prefs.enabled) ...[
            const SizedBox(height: 12),

            // Pick of the day
            _NotificationToggle(
              icon: CupertinoIcons.star,
              title: 'Pick del día',
              subtitle: 'Lun, Mié, Vie a las 7:30pm',
              value: prefs.pickOfDay,
              onChanged: (value) => notifier.setPickOfDay(value),
              isSecondary: true,
            ),

            const SizedBox(height: 12),

            // Watchlist reminder
            _NotificationToggle(
              icon: CupertinoIcons.bookmark,
              title: 'Recordatorio de watchlist',
              subtitle: 'Tu lista te espera',
              value: prefs.watchlistReminder,
              onChanged: (value) => notifier.setWatchlistReminder(value),
              isSecondary: true,
            ),

            const SizedBox(height: 12),

            // Weekly summary
            _NotificationToggle(
              icon: CupertinoIcons.calendar,
              title: 'Resumen semanal',
              subtitle: 'Domingos a las 6:00pm',
              value: prefs.weeklySummary,
              onChanged: (value) => notifier.setWeeklySummary(value),
              isSecondary: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Toggle de notificación individual
class _NotificationToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isSecondary;

  const _NotificationToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: isSecondary ? const EdgeInsets.only(left: 16) : null,
      decoration: BoxDecoration(
        color: isSecondary ? colors.surfaceElevated : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSecondary ? colors.surface : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? colors.accent : colors.textSecondary,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Toggle
          CupertinoSwitch(
            value: value,
            activeTrackColor: colors.accent,
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}
