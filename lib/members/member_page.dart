import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/cancel_dialog.dart';
import '../common/errors.dart';
import '../common/format.dart';
import '../common/theme.dart';
import '../tours/swap_page.dart';
import '../common/widgets.dart';
import '../data/tables.dart';
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import '../domain/standing.dart';
import '../domain/today.dart';
import '../domain/tontine_terms.dart';

/// "Fiche membre" (mockup board "Fiche membre").
class MemberPage extends ConsumerWidget {
  const MemberPage({
    super.key,
    required this.tontineId,
    required this.memberId,
  });

  final String tontineId;
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(tontineDetailProvider(tontineId));
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text('Lecture impossible : $error')),
        data: (detail) {
          final line = detail
              .today(today)
              .lines
              .firstWhere((l) => l.member.id == memberId);
          return _MemberView(detail: detail, line: line, today: today);
        },
      ),
    );
  }
}

class _MemberView extends ConsumerWidget {
  const _MemberView({
    required this.detail,
    required this.line,
    required this.today,
  });

  final TontineDetail detail;
  final MemberLine line;
  final Day today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = line.member;
    final terms = detail.terms;
    final phone = member.phone;
    final identity = [
      ?phone,
      formatPlaces(member.halves),
      '${formatFcfa(terms.dailyDue(member.halves))} par jour',
    ].join(' · ');
    final payments = detail.paymentsOf(member.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: 'Retour',
                  padding: EdgeInsets.zero,
                  color: AppColors.text,
                  icon: const Icon(Icons.chevron_left, size: 26),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if (phone != null)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    tooltip: 'Appeler ${member.name}',
                    padding: EdgeInsets.zero,
                    color: AppColors.primary,
                    icon: const Icon(Icons.phone_outlined, size: 22),
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Row(
                spacing: 14,
                children: [
                  InitialsAvatar(member.name, size: 56),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontFamily: AppFonts.display,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          identity,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Expanded(child: _StandingTile(standing: line.standing)),
                  Expanded(
                    child: _Tile(
                      background: AppColors.surface,
                      border: true,
                      color: AppColors.textSecondary,
                      valueColor: AppColors.text,
                      label: 'Total versé',
                      value: formatFcfa(line.standing.paid),
                      caption: 'sur ${formatFcfa(line.standing.due)} attendus',
                    ),
                  ),
                ],
              ),
              for (final slot in detail.slotsOf(member.id)) ...[
                const SizedBox(height: 12),
                _TourSection(
                  terms: terms,
                  tour: slot.tour,
                  halves: slot.halves,
                  paidOut: detail.paidOutSlotIds.contains(slot.id),
                  onSwap: () =>
                      openSwap(context, tontineId: detail.id, tour: slot.tour),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Versements',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              if (payments.isEmpty)
                const Text(
                  'Aucun versement pour l’instant.',
                  style: AppText.caption,
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (final (i, p) in payments.indexed)
                        _PaymentRow(
                          payment: p,
                          last: i == payments.length - 1,
                          onTap:
                              p.cancelled || p.method == PaymentMethod.withheld
                              ? null
                              : () => _confirmCancel(context, ref, p),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    PaymentEntry payment,
  ) async {
    // The dialog owns its text field: it returns the reason, or null when
    // the payment is kept.
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => CancelDialog(
        title: 'Annuler ce versement de ${formatFcfa(payment.amount)} ?',
        body: 'Il restera dans l’historique, barré, et ne comptera plus.',
        action: 'Annuler le versement',
      ),
    );
    if (reason == null) return;
    try {
      await ref
          .read(tontineRepositoryProvider)
          .cancelPayment(payment.id, reason: reason);
      ref.invalidate(tontineDetailProvider(detail.id));
      ref.invalidate(tontineCardsProvider);
    } catch (error, stack) {
      logError(error, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Annulation impossible.')));
      }
    }
  }
}

class _StandingTile extends StatelessWidget {
  const _StandingTile({required this.standing});

  final Standing standing;

  @override
  Widget build(BuildContext context) {
    final (background, color, label) = switch (standing.kind) {
      StandingKind.late => (
        AppColors.warningPale,
        AppColors.onWarningPale,
        'En retard',
      ),
      StandingKind.toCollect => (
        AppColors.neutralPale,
        AppColors.onNeutralPale,
        'À encaisser',
      ),
      StandingKind.upToDate => (
        AppColors.primaryPale,
        AppColors.onPrimaryPale,
        'À jour',
      ),
      StandingKind.ahead => (
        AppColors.infoPale,
        AppColors.onInfoPale,
        'En avance',
      ),
    };
    return _Tile(
      background: background,
      border: false,
      color: color,
      valueColor: color,
      label: label,
      value: formatFcfa(standing.badgeAmount),
      caption: 'à jour jusqu’au jour ${standing.upToDay}',
    );
  }
}

/// Tiles of the member page: radius 12, padding 12, 20 px value.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.background,
    required this.border,
    required this.color,
    required this.valueColor,
    required this.label,
    required this.value,
    required this.caption,
  });

  final Color background;
  final bool border;
  final Color color;
  final Color valueColor;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: border ? Border.all(color: AppColors.cardBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          Text(caption, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

/// "Son tour · Tour 12 · ven. 29 janv. 2027 · 1 000 000 F", with
/// "Échanger".
class _TourSection extends StatelessWidget {
  const _TourSection({
    required this.terms,
    required this.tour,
    required this.halves,
    required this.paidOut,
    required this.onSwap,
  });

  final TontineTerms terms;
  final int tour;
  final int halves;
  final bool paidOut;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                const Text('Son tour', style: AppText.small),
                Text(
                  'Tour $tour · '
                  '${formatDay(terms.payoutDay(tour), withYear: true)}',
                  style: AppText.rowTitle,
                ),
                Text(
                  formatFcfa(terms.potPerTour * halves ~/ halvesPerPlace),
                  style: AppText.small,
                ),
              ],
            ),
          ),
          if (paidOut)
            const Pill(
              text: 'Remis',
              background: AppColors.primaryPale,
              foreground: AppColors.onPrimaryPale,
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontFamily: AppFonts.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: onSwap,
              child: const Text('Échanger'),
            ),
        ],
      ),
    );
  }
}

String _methodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'Espèces',
  PaymentMethod.mobileMoney => 'Mobile money',
  PaymentMethod.withheld => 'Retenue sur sa cagnotte',
};

/// A payment line: padding 11 12, bottom divider; cancelled ones crossed
/// out with "annulé, « motif »".
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payment,
    required this.last,
    required this.onTap,
  });

  final PaymentEntry payment;
  final bool last;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reason = payment.cancelReason;
    final mode = payment.cancelled
        ? '${_methodLabel(payment.method)} · annulé'
              '${reason == null ? '' : ', $reason'}'
        : _methodLabel(payment.method);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 1,
                children: [
                  Text(
                    formatDay(payment.paidOn),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  Text(mode, style: AppText.small),
                ],
              ),
            ),
            Text(
              formatFcfa(payment.amount),
              style: payment.cancelled
                  ? const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    )
                  : const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
