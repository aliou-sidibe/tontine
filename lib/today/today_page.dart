import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/format.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import '../domain/standing.dart';
import '../domain/today.dart';
import '../domain/tontine_terms.dart';
import '../payout/payout_page.dart';
import 'payment_sheet.dart';
import 'today_texts.dart';

enum TodayFilter { all, toCollect, late }

/// "Aujourd'hui" (mockup board "Aujourd'hui").
class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key, required this.tontineId});

  final String tontineId;

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  var _filter = TodayFilter.all;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(tontineDetailProvider(widget.tontineId));
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text('Lecture impossible : $error')),
        data: (detail) {
          final view = detail.today(today);
          final names = {for (final m in detail.members) m.id: m.name};
          final lines = switch (_filter) {
            TodayFilter.all => view.lines,
            TodayFilter.toCollect => [
              for (final l in view.lines)
                if (l.standing.balance < 0) l,
            ],
            TodayFilter.late => [
              for (final l in view.lines)
                if (l.standing.kind == StandingKind.late) l,
            ],
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The whole screen scrolls, so the card with its payout button
              // still fits on a small phone; at rest it looks the same.
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(
                            name: detail.name,
                            terms: detail.terms,
                            view: view,
                            today: today,
                          ),
                          _TourCard(
                            terms: detail.terms,
                            view: view,
                            names: [
                              for (final id in view.beneficiaryIds)
                                names[id] ?? '',
                            ],
                            payoutLabel: view.pendingShares.isEmpty
                                ? null
                                : view.pendingShares.first.halves ==
                                      halvesPerPlace
                                ? 'Remettre la cagnotte'
                                : 'Remettre la part de '
                                      '${firstName(names[view.pendingShares.first.memberId] ?? '')}',
                            onPayout: view.payoutDue
                                ? () => openPayout(
                                    context,
                                    tontineId: widget.tontineId,
                                    slotId: view.pendingShares.first.id,
                                  )
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10,
                              children: [
                                Expanded(child: _CollectedTile(view: view)),
                                Expanded(child: _AdvanceTile(view: view)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _FilterChip(
                                  label: 'Tous · ${view.lines.length}',
                                  selected: _filter == TodayFilter.all,
                                  onTap: () =>
                                      setState(() => _filter = TodayFilter.all),
                                ),
                                _FilterChip(
                                  label: 'À encaisser · ${view.toCollectCount}',
                                  selected: _filter == TodayFilter.toCollect,
                                  onTap: () => setState(
                                    () => _filter = TodayFilter.toCollect,
                                  ),
                                ),
                                _FilterChip(
                                  label: 'En retard · ${view.lateCount}',
                                  selected: _filter == TodayFilter.late,
                                  onTap: () => setState(
                                    () => _filter = TodayFilter.late,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.separated(
                        itemCount: lines.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => MemberRowTile(
                          line: lines[i],
                          subtitle: rowSubtitle(
                            lines[i],
                            detail.terms,
                            view.payoutDay,
                          ),
                          onLongPress: () => showPaymentSheet(
                            context,
                            ref,
                            detail: detail,
                            line: lines[i],
                            today: today,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Appui long sur un membre pour enregistrer un versement',
                  textAlign: TextAlign.center,
                  style: AppText.small,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.terms,
    required this.view,
    required this.today,
  });

  final String name;
  final TontineTerms terms;
  final TodayView view;
  final Day today;

  @override
  Widget build(BuildContext context) {
    final day = view.dayNumber;
    final title = day < 1
        ? Text(
            'Début dans ${1 - day} jour${1 - day > 1 ? 's' : ''}',
            style: AppText.screenTitle,
          )
        : Text.rich(
            TextSpan(
              text: 'Jour ${day > terms.totalDays ? terms.totalDays : day} ',
              children: [
                TextSpan(
                  text: 'sur ${terms.totalDays}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            style: AppText.screenTitle,
          );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(name, style: AppText.caption),
                title,
                Text(
                  formatDay(today, withYear: true),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                shape: const CircleBorder(),
              ),
              // Back to "Mes tontines" to pick another tontine.
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Icon(
                Icons.unfold_more,
                size: 20,
                semanticLabel: 'Changer de tontine',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The green card of the current tour.
class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.terms,
    required this.view,
    required this.names,
    required this.payoutLabel,
    required this.onPayout,
  });

  final TontineTerms terms;
  final TodayView view;
  final List<String> names;
  final String? payoutLabel;

  /// Set once the payout day has come: opens "Remise de la cagnotte".
  final VoidCallback? onPayout;

  @override
  Widget build(BuildContext context) {
    final tour = view.currentTour;
    final ratio = view.expected == 0
        ? 0.0
        : (view.collected / view.expected).clamp(0.0, 1.0);
    const white = TextStyle(color: Colors.white);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 8,
            children: [
              Flexible(
                child: Text(
                  'TOUR $tour SUR ${terms.tours}',
                  style: white.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.26,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  'jours ${terms.firstDayOfTour(tour)} à '
                  '${terms.lastDayOfTour(tour)}',
                  textAlign: TextAlign.end,
                  style: white.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                collectorsTitle(names),
                style: white.copyWith(
                  fontFamily: AppFonts.display,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                payoutLine(view.payoutDay, view.daysToPayout, terms.potPerTour),
                style: white.copyWith(fontSize: 14),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.onPrimaryTrack,
              color: Colors.white,
            ),
          ),
          Text(
            progressLine(view.collected, view.expected),
            style: white.copyWith(fontSize: 13),
          ),
          // Not in the mockup (day 37): from the payout day on, the card
          // leads to "Remise de la cagnotte".
          if (onPayout != null && payoutLabel != null)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: AppFonts.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: onPayout,
              child: Text(payoutLabel!),
            ),
        ],
      ),
    );
  }
}

class _CollectedTile extends StatelessWidget {
  const _CollectedTile({required this.view});

  final TodayView view;

  @override
  Widget build(BuildContext context) {
    return _Tile(
      background: AppColors.surface,
      border: true,
      color: AppColors.textSecondary,
      valueColor: AppColors.text,
      label: 'Encaissé aujourd\'hui',
      value: formatFcfa(view.collectedToday),
      caption: 'sur ${formatFcfa(view.expectedToday)}',
    );
  }
}

class _AdvanceTile extends StatelessWidget {
  const _AdvanceTile({required this.view});

  final TodayView view;

  @override
  Widget build(BuildContext context) {
    final owed = view.toRecover > 0;
    return _Tile(
      background: owed ? AppColors.warningPale : AppColors.surface,
      border: !owed,
      color: owed ? AppColors.onWarningPale : AppColors.textSecondary,
      valueColor: owed ? AppColors.onWarningPale : AppColors.text,
      label: 'Avancé par toi',
      value: formatFcfa(view.toRecover),
      caption: toRecoverLine(view),
    );
  }
}

/// The two tiles under the card: radius 12, padding 12, 18 px value.
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
              fontSize: 18,
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

/// 36 px filters; the selected one is dark.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.text : AppColors.surface,
        shape: StadiumBorder(
          side: selected
              ? BorderSide.none
              : const BorderSide(color: AppColors.controlBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge colors by standing, as in the mockup.
(Color, Color) badgeColors(MemberLine line) => switch (line.standing.kind) {
  StandingKind.late => (AppColors.warningPale, AppColors.onWarningPale),
  StandingKind.toCollect => (AppColors.neutralPale, AppColors.onNeutralPale),
  StandingKind.upToDate => (AppColors.primaryPale, AppColors.onPrimaryPale),
  StandingKind.ahead => (AppColors.infoPale, AppColors.onInfoPale),
};

/// A member row (radius 12, padding 10 12, 36 px avatar, badge on the
/// right). On "Aujourd'hui" only a long press acts; it shrinks slightly as
/// soon as the finger is down (apple-design: immediate feedback).
class MemberRowTile extends StatefulWidget {
  const MemberRowTile({
    super.key,
    required this.line,
    required this.subtitle,
    this.onLongPress,
    this.onTap,
  });

  final MemberLine line;
  final String subtitle;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  @override
  State<MemberRowTile> createState() => _MemberRowTileState();
}

class _MemberRowTileState extends State<MemberRowTile> {
  var _pressed = false;

  void _press(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = badgeColors(widget.line);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      onLongPressHint: widget.onLongPress == null
          ? null
          : 'enregistrer un versement',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press(true),
        onTapUp: (_) => _press(false),
        onTapCancel: () => _press(false),
        onTap: widget.onTap,
        onLongPressStart: widget.onLongPress == null
            ? null
            : (_) => HapticFeedback.mediumImpact(),
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _press(false);
                widget.onLongPress!();
              },
        onLongPressEnd: (_) => _press(false),
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? 0.98 : 1,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              spacing: 12,
              children: [
                InitialsAvatar(widget.line.member.name),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 1,
                    children: [
                      Text(widget.line.member.name, style: AppText.rowTitle),
                      Text(widget.subtitle, style: AppText.small),
                    ],
                  ),
                ),
                Pill(
                  text: badgeText(widget.line),
                  background: background,
                  foreground: foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
