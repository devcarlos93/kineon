import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kino_mascot.dart';
import '../../../home/domain/entities/movie_details.dart';
import '../../domain/cinema_links.dart';

/// Sección "Ver en Cines" que aparece cuando una película está en cartelera.
class InTheatersSection extends ConsumerWidget {
  final MovieDetails details;

  const InTheatersSection({super.key, required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isInTheaters(details)) return const SizedBox.shrink();

    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.theaters, color: colors.accent, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.inTheaters,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              const KinoAvatar(mood: KinoMood.excited, size: 28),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.inTheatersKinoMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),

          // Grid 2x2
          Row(
            children: [
              Expanded(
                child: _OptionCard(
                  icon: Icons.location_on_outlined,
                  label: l10n.inTheatersFindCinemas,
                  onTap: () => _openGoogleMaps(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionCard(
                  icon: Icons.schedule_outlined,
                  label: l10n.inTheatersShowtimes,
                  onTap: () => _openShowtimes(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OptionCard(
                  icon: Icons.notifications_outlined,
                  label: l10n.inTheatersRemindMe,
                  onTap: () => _scheduleReminder(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionCard(
                  icon: Icons.share_outlined,
                  label: l10n.inTheatersInviteFriends,
                  onTap: () => _inviteFriends(context),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 280.ms);
  }

  void _openGoogleMaps() {
    final uri = Uri.parse('https://www.google.com/maps/search/cines+cerca+de+mi');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openShowtimes() {
    final query = Uri.encodeComponent('${details.title} horarios cine');
    final uri = Uri.parse('https://www.google.com/search?q=$query');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _scheduleReminder(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final now = DateTime.now();

    // 1. Elegir fecha
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: colors.accent,
                surface: colors.surface,
              ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !context.mounted) return;

    // 2. Elegir hora
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: colors.accent,
                surface: colors.surface,
              ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null || !context.mounted) return;

    // 3. Combinar fecha + hora
    final reminderDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (reminderDate.isBefore(now)) return;

    // 4. Programar notificación
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.scheduleCinemaReminder(
      movieId: details.id,
      movieTitle: details.title,
      reminderDate: reminderDate,
    );

    if (!context.mounted) return;

    // 5. Confirmar con fecha legible
    final day = '${pickedDate.day}/${pickedDate.month}';
    final time = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.inTheatersReminderSet} - $day $time'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _inviteFriends(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = l10n.inTheatersShareText(details.title);
    Share.share(text);
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.accent.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
