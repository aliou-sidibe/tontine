import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../common/format.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../creation/creation_page.dart';
import '../data/tontine_repository.dart';
import '../home/last_tontine.dart';

/// "Mes tontines" (mockup board "Mes tontines").
class TontinesPage extends ConsumerStatefulWidget {
  const TontinesPage({super.key});

  @override
  ConsumerState<TontinesPage> createState() => _TontinesPageState();
}

class _TontinesPageState extends ConsumerState<TontinesPage> {
  @override
  void initState() {
    super.initState();
    // Reopen the tontine left open last time, if it still exists.
    final last = ref.read(lastTontineStoreProvider).read();
    if (last != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final cards = await ref.read(tontineCardsProvider.future);
        if (mounted && cards.any((c) => c.id == last)) {
          await openTontine(context, ref, last);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(tontineCardsProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('Ma Tontine', style: AppText.caption),
                  Text('Mes tontines', style: AppText.homeTitle),
                ],
              ),
            ),
            Expanded(
              child: cards.when(
                data: (list) => _TontineList(
                  cards: list,
                  onOpen: (id) => openTontine(context, ref, id),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Lecture impossible : $error',
                    style: AppText.body,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CreationPage(),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Nouvelle tontine'),
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      const Expanded(
                        child: OutlinedButton(
                          // Wired in step 6 (sauvegarde).
                          onPressed: null,
                          child: Text('Sauvegarde'),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showAccount(context),
                          child: const Text('Mon compte'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccount(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.sheetHandle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Mon compte', style: AppText.screenTitle),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(sheet).pop();
                  ref.read(sessionProvider.notifier).logout();
                },
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TontineList extends StatelessWidget {
  const _TontineList({required this.cards, required this.onOpen});

  final List<TontineCard> cards;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final running = [
      for (final c in cards)
        if (!c.overview.finished) c,
    ];
    final finished = [
      for (final c in cards)
        if (c.overview.finished) c,
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text('EN COURS', style: AppText.sectionLabel),
        const SizedBox(height: 12),
        if (running.isEmpty) const _EmptyCard(),
        for (final card in running)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RunningCard(card: card, onTap: () => onOpen(card.id)),
          ),
        if (finished.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('TERMINÉES', style: AppText.sectionLabel),
          const SizedBox(height: 12),
          for (final card in finished)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FinishedCard(card: card, onTap: () => onOpen(card.id)),
            ),
        ],
      ],
    );
  }
}

/// White card, radius 16, padding 16, border #E3E7E4.
class _Card extends StatelessWidget {
  const _Card({required this.gap, required this.children, this.onTap});

  final double gap;
  final VoidCallback? onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// "Tour 4 : Koffi Yao ramasse le mar. 10 nov."
String beneficiaryLine(TontineCard card) {
  final o = card.overview;
  final names = [for (final id in o.beneficiaryIds) card.memberNames[id] ?? ''];
  final who = names.length == 2
      ? '${names[0]} et ${names[1]} ramassent'
      : '${names.isEmpty ? '' : names.single} ramasse';
  return 'Tour ${o.currentTour} : $who le ${formatDay(o.payoutDay)}';
}

class RunningCard extends StatelessWidget {
  const RunningCard({super.key, required this.card, this.onTap});

  final TontineCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final o = card.overview;
    final terms = card.terms;
    final progress = (o.dayNumber / terms.totalDays).clamp(0.0, 1.0);
    return _Card(
      onTap: onTap,
      gap: 10,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                card.name,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            Text(
              o.started
                  ? 'Jour ${o.dayNumber > terms.totalDays ? terms.totalDays : o.dayNumber} / ${terms.totalDays}'
                  : 'Commence le ${formatDay(terms.firstDay)}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.segmentTrackScreen,
            color: AppColors.primary,
          ),
        ),
        Text(
          termsLine(terms),
          style: const TextStyle(fontSize: 13, color: AppColors.onNeutralPale),
        ),
        Text(
          beneficiaryLine(card),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        if (o.lateCount > 0 || o.toRecover > 0)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (o.lateCount > 0)
                Pill(
                  text: '${o.lateCount} en retard',
                  background: AppColors.warningPale,
                  foreground: AppColors.onWarningPale,
                ),
              if (o.toRecover > 0)
                Pill(
                  text: '${formatFcfa(o.toRecover)} à récupérer',
                  background: AppColors.warningPale,
                  foreground: AppColors.onWarningPale,
                ),
            ],
          ),
      ],
    );
  }
}

class FinishedCard extends StatelessWidget {
  const FinishedCard({super.key, required this.card, this.onTap});

  final TontineCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final o = card.overview;
    final terms = card.terms;
    return _Card(
      onTap: onTap,
      gap: 6,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                card.name,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            const Pill(
              text: 'Terminée',
              background: AppColors.primaryPale,
              foreground: AppColors.onPrimaryPale,
            ),
          ],
        ),
        Text(
          '${terms.places} place${terms.places > 1 ? 's' : ''} · '
          '${formatFcfa(terms.contributionPerPlace)} par jour · '
          '${o.toursPaidOut} tour${o.toursPaidOut > 1 ? 's' : ''} '
          'remis',
          style: const TextStyle(fontSize: 13, color: AppColors.onNeutralPale),
        ),
        Text(
          o.toRecover > 0
              ? '${formatFcfa(o.toRecover)} à récupérer'
              : 'Rien à récupérer',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      gap: 6,
      children: [
        Text(
          'Aucune tontine pour l’instant',
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        Text(
          'Créez la première avec « Nouvelle tontine ».',
          style: TextStyle(fontSize: 13, color: AppColors.onNeutralPale),
        ),
      ],
    );
  }
}
