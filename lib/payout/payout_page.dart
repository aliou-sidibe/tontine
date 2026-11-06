import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/errors.dart';
import '../common/format.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../data/tables.dart';
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import '../domain/payout.dart';
import '../domain/tontine_terms.dart';
import '../today/today_texts.dart';

/// Opens "Remise de la cagnotte" for one share, over the bottom bar.
Future<void> openPayout(
  BuildContext context, {
  required String tontineId,
  required String slotId,
}) => Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute<void>(
    builder: (_) => PayoutPage(tontineId: tontineId, slotId: slotId),
  ),
);

/// "Remise de la cagnotte" (mockup board "Remise de la cagnotte").
class PayoutPage extends ConsumerStatefulWidget {
  const PayoutPage({super.key, required this.tontineId, required this.slotId});

  final String tontineId;
  final String slotId;

  @override
  ConsumerState<PayoutPage> createState() => _PayoutPageState();
}

class _PayoutPageState extends ConsumerState<PayoutPage> {
  var _method = PayoutMethod.cash;
  var _saving = false;

  Future<void> _confirm(String name, int handed) async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(tontineRepositoryProvider)
          .recordPayout(
            tontineId: widget.tontineId,
            slotId: widget.slotId,
            method: _method,
            day: ref.read(todayProvider),
          );
      // apple-design: haptic on the moment that matters, never awaited.
      unawaited(HapticFeedback.mediumImpact());
      ref.invalidate(tontineDetailProvider(widget.tontineId));
      ref.invalidate(tontineCardsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.text,
          content: Text('${formatFcfa(handed)} remis à ${firstName(name)}'),
        ),
      );
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
          const SnackBar(content: Text('Remise impossible.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(tontineDetailProvider(widget.tontineId));
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackHeader(
              title: 'Remise de la cagnotte',
              bottom: 8,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: detail.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) =>
                    Center(child: Text('Lecture impossible : $error')),
                data: (detail) => _content(detail, today),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(TontineDetail detail, Day today) {
    final terms = detail.terms;
    final slot = detail.slots.firstWhere((s) => s.id == widget.slotId);
    final names = {for (final m in detail.members) m.id: m.name};
    final name = names[slot.memberId] ?? '';
    final first = firstName(name);
    final b = detail.payoutFor(slot.id);
    final topUps = detail.topUpsFor(slot.tour);
    final due =
        !detail.paidOutSlotIds.contains(slot.id) &&
        !today.isBefore(terms.payoutDay(slot.tour));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _BeneficiaryCard(terms: terms, tour: slot.tour, name: name),
              const SizedBox(height: 12),
              _Calculation(
                breakdown: b,
                topUpCaption: _topUpCaption(topUps, names, slot.halves),
                firstName: first,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Text(
                        'À remettre à $first',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      formatFcfa(b.handed),
                      style: const TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Remis en',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              MethodSwitch<PayoutMethod>(
                options: const [
                  (PayoutMethod.cash, 'Espèces'),
                  (PayoutMethod.mobileMoney, 'Mobile money'),
                ],
                method: _method,
                track: AppColors.segmentTrackScreen,
                label: 'Mode de remise',
                onChanged: (m) => setState(() => _method = m),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              FilledButton(
                onPressed: due && !_saving
                    ? () => _confirm(name, b.handed)
                    : null,
                child: Text('Confirmer la remise de ${formatFcfa(b.handed)}'),
              ),
              const Text(
                'Une remise confirmée s’annule seulement par une '
                'contre-écriture.',
                textAlign: TextAlign.center,
                style: AppText.small,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Seydou Koné 25 000 F · Moussa Diallo 15 000 F. Ils te les devront."
String _topUpCaption(
  Map<String, int> topUps,
  Map<String, String> names,
  int halves,
) {
  if (topUps.isEmpty) return 'Tout le monde a payé ce tour.';
  final list = [
    for (final e in topUps.entries) '${names[e.key]} ${formatFcfa(e.value)}',
  ].join(' · ');
  final shared = halves == halvesPerPlace
      ? ''
      : ', partagés entre les deux demi-places';
  final owe = topUps.length == 1
      ? '${firstName(names[topUps.keys.single] ?? '')} te les devra.'
      : 'Ils te les devront.';
  return '$list$shared. $owe';
}

/// "TOUR 4 · JOURS 31 À 40", the beneficiary, "mar. 10 nov. 2026 ·
/// lendemain du jour 40".
class _BeneficiaryCard extends StatelessWidget {
  const _BeneficiaryCard({
    required this.terms,
    required this.tour,
    required this.name,
  });

  final TontineTerms terms;
  final int tour;
  final String name;

  @override
  Widget build(BuildContext context) {
    final last = terms.lastDayOfTour(tour);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            'TOUR $tour · JOURS ${terms.firstDayOfTour(tour)} À $last',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          Text(
            '${formatDay(terms.payoutDay(tour), withYear: true)} · '
            'lendemain du jour $last',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The calculation card: pot, paid by members, top-up, withholding.
class _Calculation extends StatelessWidget {
  const _Calculation({
    required this.breakdown,
    required this.topUpCaption,
    required this.firstName,
  });

  final PayoutBreakdown breakdown;
  final String topUpCaption;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final b = breakdown;
    final topUpColor = b.organizerTopUp > 0
        ? AppColors.onWarningPale
        : AppColors.text;
    return Semantics(
      label: 'Calcul',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PlainLine('Cagnotte du tour', formatFcfa(b.pot)),
            _PlainLine('Versé par les membres', formatFcfa(b.collected)),
            _DetailedLine(
              label: 'Tu complètes de ta poche',
              value: b.organizerTopUp > 0
                  ? '+ ${formatFcfa(b.organizerTopUp)}'
                  : formatFcfa(0),
              color: topUpColor,
              caption: topUpCaption,
              divider: true,
            ),
            _DetailedLine(
              label: b.withheld > 0
                  ? 'Retenue : retard de $firstName'
                  : 'Pas de retenue',
              value: b.withheld > 0
                  ? '− ${formatFcfa(b.withheld)}'
                  : formatFcfa(0),
              color: AppColors.text,
              caption: b.withheld == 0
                  ? '$firstName est à jour.'
                  : b.withheld < b.arrears
                  ? '$firstName reste en retard de '
                        '${formatFcfa(b.arrears - b.withheld)}.'
                  : '$firstName est remis à jour.',
              divider: false,
            ),
          ],
        ),
      ),
    );
  }
}

const _divider = Border(bottom: BorderSide(color: AppColors.divider));

/// "Cagnotte du tour · 1 000 000 F": 14 px, value 600, divider below.
class _PlainLine extends StatelessWidget {
  const _PlainLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(border: _divider),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.text),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    ),
  );
}

/// A line with a 12 px caption: label 600, value 700.
class _DetailedLine extends StatelessWidget {
  const _DetailedLine({
    required this.label,
    required this.value,
    required this.color,
    required this.caption,
    required this.divider,
  });

  final String label;
  final String value;
  final Color color;
  final String caption;
  final bool divider;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(border: divider ? _divider : null),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        Text(caption, style: AppText.small),
      ],
    ),
  );
}
