import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/errors.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../creation/creation_page.dart' show TourRow;
import '../data/tontine_repository.dart';
import 'tours_page.dart';

/// Opens "Échanger deux tours" over the bottom bar, with [tour] already
/// chosen when it comes from a member page.
Future<void> openSwap(
  BuildContext context, {
  required String tontineId,
  int? tour,
}) => Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute<void>(
    builder: (_) => SwapPage(tontineId: tontineId, initialTour: tour),
  ),
);

/// "Échanger deux tours" (not in the mockup; same style as "Tours"). Only
/// tours not handed out yet can be picked.
class SwapPage extends ConsumerStatefulWidget {
  const SwapPage({super.key, required this.tontineId, this.initialTour});

  final String tontineId;
  final int? initialTour;

  @override
  ConsumerState<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends ConsumerState<SwapPage> {
  late final _chosen = <int>[?widget.initialTour];
  var _saving = false;

  void _toggle(int tour) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_chosen.remove(tour)) {
        // A third choice replaces the second one.
        if (_chosen.length == 2) _chosen.removeLast();
        _chosen.add(tour);
      }
    });
  }

  Future<void> _swap() async {
    final [a, b] = _chosen;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(tontineRepositoryProvider)
          .swapTours(tontineId: widget.tontineId, tourA: a, tourB: b);
      unawaited(HapticFeedback.mediumImpact());
      ref.invalidate(tontineDetailProvider(widget.tontineId));
      ref.invalidate(tontineCardsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.text,
          content: Text('Tours $a et $b échangés'),
        ),
      );
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
          const SnackBar(content: Text('Échange impossible.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(tontineDetailProvider(widget.tontineId));
    final today = ref.watch(todayProvider);
    final sorted = [..._chosen]..sort();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackHeader(
              title: 'Échanger deux tours',
              bottom: 8,
              onBack: () => Navigator.of(context).pop(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'Choisis les deux tours à échanger. Seuls les tours pas encore '
                'ramassés peuvent l’être.',
                style: AppText.small,
              ),
            ),
            Expanded(
              child: detail.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) =>
                    Center(child: Text('Lecture impossible : $error')),
                data: (detail) {
                  final entries = tourEntries(detail, today);
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final e = entries[i];
                      // Even half handed out, a tour can no longer move.
                      final done = detail
                          .sharesOf(e.tour)
                          .any((s) => detail.paidOutSlotIds.contains(s.id));
                      final chosen = _chosen.contains(e.tour);
                      return Semantics(
                        selected: chosen,
                        child: TourRow(
                          number: e.tour,
                          who: e.who,
                          date: e.date,
                          onTap: done ? null : () => _toggle(e.tour),
                          trailing: done
                              ? const Pill(
                                  text: 'Remis',
                                  background: AppColors.primaryPale,
                                  foreground: AppColors.onPrimaryPale,
                                )
                              : Icon(
                                  chosen
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 24,
                                  color: chosen
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            BottomAction(
              label: sorted.length == 2
                  ? 'Échanger les tours ${sorted[0]} et ${sorted[1]}'
                  : 'Choisis deux tours',
              onPressed: sorted.length == 2 && !_saving ? _swap : null,
            ),
          ],
        ),
      ),
    );
  }
}
