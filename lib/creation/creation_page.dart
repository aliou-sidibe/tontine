import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/errors.dart';
import '../common/format.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import '../domain/draft.dart';
import '../domain/tontine_terms.dart';
import 'creation_state.dart';
import 'member_sheet.dart';

/// "Nouvelle tontine": four steps in one page, so the draft survives going
/// back and forth. The system back button goes to the previous step.
class CreationPage extends ConsumerWidget {
  const CreationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(creationProvider.select((d) => d.step));
    void back() {
      if (step == 1) {
        Navigator.of(context).pop();
      } else {
        ref.read(creationProvider.notifier).goTo(step - 1);
      }
    }

    return PopScope(
      canPop: step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BackHeader(title: 'Nouvelle tontine', onBack: back),
              CreationSteps(current: step),
              Expanded(
                child: switch (step) {
                  1 => const ParametersStep(),
                  2 => const MembersStep(),
                  3 => const OrderStep(),
                  _ => const RecapStep(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 · Paramètres (mockup board "Nouvelle tontine · paramètres")
// ---------------------------------------------------------------------------

class ParametersStep extends ConsumerStatefulWidget {
  const ParametersStep({super.key});

  @override
  ConsumerState<ParametersStep> createState() => _ParametersStepState();
}

class _ParametersStepState extends ConsumerState<ParametersStep> {
  late final TextEditingController _name;
  late final TextEditingController _places;
  late final TextEditingController _tourDays;
  late final TextEditingController _contribution;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(creationProvider);
    _name = TextEditingController(text: draft.name);
    _places = TextEditingController(text: draft.places?.toString() ?? '');
    _tourDays = TextEditingController(text: draft.tourDays?.toString() ?? '');
    _contribution = TextEditingController(
      text: draft.contributionPerPlace == null
          ? ''
          : formatNumber(draft.contributionPerPlace!),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _places.dispose();
    _tourDays.dispose();
    _contribution.dispose();
    super.dispose();
  }

  Future<void> _pickFirstDay(Day current) async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('fr'),
      initialDate: DateTime(current.year, current.month, current.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ref.read(creationProvider.notifier).setFirstDay(Day.fromDateTime(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final contribution = draft.contributionPerPlace;
    final contributionInvalid = contribution != null && contribution % 10 != 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              LabeledBox(
                label: 'Nom de la tontine',
                child: BareInput(
                  controller: _name,
                  hint: 'Tontine du marché',
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: notifier.setName,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Expanded(
                    child: LabeledBox(
                      label: 'Nombre de places',
                      child: BareInput(
                        controller: _places,
                        numeric: true,
                        hint: '20',
                        onChanged: (v) => notifier.setPlaces(int.tryParse(v)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LabeledBox(
                      label: 'Durée d’un tour',
                      child: BareInput(
                        controller: _tourDays,
                        numeric: true,
                        unit: 'jours',
                        hint: '10',
                        onChanged: (v) => notifier.setTourDays(int.tryParse(v)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LabeledBox(
                label: 'Cotisation par place et par jour',
                helper: contributionInvalid
                    ? 'La cotisation doit être un multiple de 10 F'
                    : contribution == null
                    ? null
                    : 'Une demi-place cotise '
                          '${formatFcfa(contribution ~/ 2)}, deux places '
                          '${formatFcfa(contribution * 2)}',
                helperIsWarning: contributionInvalid,
                child: BareInput(
                  controller: _contribution,
                  numeric: true,
                  groupThousands: true,
                  unit: 'F',
                  hint: '5 000',
                  onChanged: (v) => notifier.setContribution(parseAmount(v)),
                ),
              ),
              const SizedBox(height: 10),
              LabeledBox(
                label: 'Premier jour de cotisation',
                onTap: () => _pickFirstDay(draft.firstDay),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    formatDay(draft.firstDay, withYear: true),
                    style: fieldValueStyle,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CalculationCard(terms: draft.terms),
              const SizedBox(height: 10),
            ],
          ),
        ),
        BottomAction(
          label: 'Suivant : les membres',
          onPressed: draft.parametersValid ? () => notifier.goTo(2) : null,
        ),
      ],
    );
  }
}

/// "Calculé par l'appli": the green card of the parameters step.
class CalculationCard extends StatelessWidget {
  const CalculationCard({super.key, required this.terms});

  final TontineTerms? terms;

  @override
  Widget build(BuildContext context) {
    final t = terms;
    String value(String Function(TontineTerms t) of) => t == null ? '—' : of(t);
    return Semantics(
      label: 'Calcul automatique',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryPale,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            const Text(
              'CALCULÉ PAR L’APPLI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimaryPale,
                letterSpacing: 0.48,
              ),
            ),
            _CalcRow(
              'Chaque place verse par tour',
              value((t) => formatFcfa(t.perPlacePerTour)),
            ),
            _CalcRow(
              'Cagnotte d’un tour',
              value((t) => formatFcfa(t.potPerTour)),
            ),
            _CalcRow(
              'Durée totale',
              value(
                (t) =>
                    '${t.tours} tour${t.tours > 1 ? 's' : ''} · '
                    '${t.totalDays} jours',
              ),
            ),
            _CalcRow(
              'Premier ramassage',
              value((t) => formatDay(t.payoutDay(1), withYear: true)),
            ),
            _CalcRow(
              'Dernier ramassage',
              value((t) => formatDay(t.payoutDay(t.tours), withYear: true)),
            ),
            const Text(
              'Tous les jours comptent. Le ramassage a lieu le lendemain du '
              'dernier jour du tour.',
              style: TextStyle(fontSize: 12, color: AppColors.onPrimaryPale),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  const _CalcRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        Flexible(child: Text(label, style: AppText.body)),
        Text(value, style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 · Membres (not in the mockup: same style as "Ordre des tours")
// ---------------------------------------------------------------------------

/// "18 places sur 20", "19 places ½ sur 20".
String placesCount(int halves) {
  final whole = halves ~/ 2;
  final half = halves.isOdd ? '½' : '';
  if (whole == 0 && half.isNotEmpty) return '½ place';
  return '$whole${half.isEmpty ? '' : ' ½'} place${whole > 1 ? 's' : ''}';
}

class MembersStep extends ConsumerWidget {
  const MembersStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(creationProvider);
    final terms = draft.terms!;
    final halves = totalHalves(draft.members);
    final problem = membersProblem(terms, draft.members);
    final expected = terms.places * halvesPerPlace;
    final banner = switch (problem) {
      null => '${placesCount(halves)} sur ${terms.places}',
      MembersProblem.missingPlaces =>
        '${placesCount(halves)} sur ${terms.places} · il manque '
            '${placesCount(expected - halves)}',
      MembersProblem.tooManyPlaces =>
        '${placesCount(halves)} sur ${terms.places} · '
            '${placesCount(halves - expected)} en trop',
      MembersProblem.unnamedMember => 'Un membre n’a pas de nom',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8,
                children: [
                  const Flexible(child: SectionTitle('Qui participe ?')),
                  SmallAction(
                    icon: Icons.add,
                    label: 'Ajouter',
                    onPressed: () => showMemberSheet(
                      context,
                      contribution: terms.contributionPerPlace,
                    ),
                  ),
                ],
              ),
              CheckBanner(text: banner, ok: problem == null),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: draft.members.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ajoutez les membres un par un, avec leur nombre de '
                    'places : ½, 1, 2…',
                    style: AppText.caption,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: draft.members.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final member = draft.members[i];
                    final details = [
                      formatPlaces(member.halves),
                      if (member.halves != 2)
                        '${formatFcfa(terms.dailyDue(member.halves))} par jour',
                      ?member.phone,
                    ].join(' · ');
                    return RowCard(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      onTap: () => showMemberSheet(
                        context,
                        contribution: terms.contributionPerPlace,
                        member: member,
                      ),
                      child: Row(
                        spacing: 12,
                        children: [
                          InitialsAvatar(member.name),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 1,
                              children: [
                                Text(member.name, style: AppText.rowTitle),
                                Text(details, style: AppText.small),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        BottomAction(
          label: 'Suivant : l’ordre des tours',
          onPressed: problem == null
              ? () => ref.read(creationProvider.notifier).goTo(3)
              : null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 · Ordre (mockup board "Nouvelle tontine · ordre des tours")
// ---------------------------------------------------------------------------

/// "Mariam Traoré · place 1 sur 2", "Fatou Bamba ½ + Aminata Koné ½".
String tourWho(DraftTour tour, Map<String, String> names) {
  if (tour.length == 2) {
    return tour.map((s) => '${names[s.memberKey]} ½').join(' + ');
  }
  final share = tour.single;
  final name = names[share.memberKey] ?? '';
  return share.placeCount > 1
      ? '$name · place ${share.placeIndex} sur ${share.placeCount}'
      : name;
}

/// "mer. 30 déc. 2026 · 500 000 F chacune" for a tour of two halves.
String tourDate(TontineTerms terms, int tourNumber, DraftTour tour) {
  final date = formatDay(terms.payoutDay(tourNumber), withYear: true);
  return tour.length == 2
      ? '$date · ${formatFcfa(terms.potPerTour ~/ 2)} chacune'
      : date;
}

String _halvesBanner(TontineTerms terms, List<DraftMember> members) {
  final count = halfPlaceCount(members);
  final base = '${terms.places} places sur ${terms.places}';
  return count == 0 ? base : '$base · les $count demi-places sont associées';
}

class OrderStep extends ConsumerWidget {
  const OrderStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(creationProvider);
    final terms = draft.terms!;
    final tours = draft.tours ?? const [];
    final names = {for (final m in draft.members) m.key: m.name};
    final notifier = ref.read(creationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8,
                children: [
                  const Flexible(child: SectionTitle('Qui ramasse quand ?')),
                  SmallAction(
                    icon: Icons.shuffle,
                    label: 'Tirer au sort',
                    onPressed: notifier.draw,
                  ),
                ],
              ),
              CheckBanner(text: _halvesBanner(terms, draft.members), ok: true),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            buildDefaultDragHandles: false,
            itemCount: tours.length,
            // apple-design: feedback when the tour is picked up and dropped.
            onReorderStart: (_) => HapticFeedback.selectionClick(),
            onReorderItem: (from, to) {
              HapticFeedback.lightImpact();
              notifier.moveTour(from, to);
            },
            itemBuilder: (context, i) => Padding(
              key: ValueKey('tour-$i-${tourWho(tours[i], names)}'),
              padding: const EdgeInsets.only(bottom: 6),
              child: TourRow(
                number: i + 1,
                who: tourWho(tours[i], names),
                date: tourDate(terms, i + 1, tours[i]),
                handle: ReorderableDragStartListener(
                  index: i,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.drag_indicator,
                      size: 18,
                      color: AppColors.textTertiary,
                      semanticLabel: 'Déplacer',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        BottomAction(
          label: 'Suivant : récapitulatif',
          onPressed: tours.length == terms.tours
              ? () => notifier.goTo(4)
              : null,
        ),
      ],
    );
  }
}

/// A row of "Ordre des tours": number (30 px wide, 15 px bold), who (600 14
/// px), date (12 px), and the drag handle.
class TourRow extends StatelessWidget {
  const TourRow({
    super.key,
    required this.number,
    required this.who,
    required this.date,
    this.handle,
    this.trailing,
    this.onTap,
  });

  final int number;
  final String who;
  final String date;
  final VoidCallback? onTap;

  /// Drag handle of the order step (44 px, so the row's right padding is 4).
  final Widget? handle;

  /// Status badge of the calendar.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return RowCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(12, 8, handle == null ? 12 : 4, 8),
      child: Row(
        spacing: 12,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$number',
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(
                  who,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(date, style: AppText.small),
              ],
            ),
          ),
          ?handle,
          ?trailing,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4 · Récap (not in the mockup: same style as the previous steps)
// ---------------------------------------------------------------------------

class RecapStep extends ConsumerStatefulWidget {
  const RecapStep({super.key});

  @override
  ConsumerState<RecapStep> createState() => _RecapStepState();
}

class _RecapStepState extends ConsumerState<RecapStep> {
  var _saving = false;
  String? _error;

  Future<void> _start(CreationDraft draft) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(tontineRepositoryProvider)
          .create(
            name: draft.name,
            terms: draft.terms!,
            members: draft.members,
            tours: draft.tours!,
          );
      ref.invalidate(tontineCardsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Enregistrement impossible. Réessayez.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(creationProvider);
    final terms = draft.terms!;
    final tours = draft.tours ?? const [];
    final names = {for (final m in draft.members) m.key: m.name};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SectionTitle('Tout est prêt ?'),
              const SizedBox(height: 10),
              RowCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      draft.name.trim(),
                      style: const TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      termsLine(terms),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onNeutralPale,
                      ),
                    ),
                    Text(
                      '${draft.members.length} membre'
                      '${draft.members.length > 1 ? 's' : ''} · début le '
                      '${formatDay(terms.firstDay, withYear: true)}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              CalculationCard(terms: terms),
              const SizedBox(height: 18),
              const Text('CALENDRIER', style: AppText.sectionLabel),
              const SizedBox(height: 10),
              for (final (i, tour) in tours.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: TourRow(
                    number: i + 1,
                    who: tourWho(tour, names),
                    date: tourDate(terms, i + 1, tour),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: AppText.body.copyWith(
                      color: AppColors.onWarningPale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        BottomAction(
          label: 'Démarrer la tontine',
          onPressed: _saving ? null : () => _start(draft),
        ),
      ],
    );
  }
}

/// "20 places · 5 000 F par jour · tours de 10 jours".
String termsLine(TontineTerms terms) =>
    '${terms.places} place${terms.places > 1 ? 's' : ''} · '
    '${formatFcfa(terms.contributionPerPlace)} par jour · '
    'tours de ${terms.tourDays} jour${terms.tourDays > 1 ? 's' : ''}';
