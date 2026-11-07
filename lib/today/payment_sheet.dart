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
import '../domain/standing.dart';
import '../domain/today.dart';
import 'today_texts.dart';

/// Opens "Versement de …" (mockup board "Versement (appui long)").
Future<void> showPaymentSheet(
  BuildContext context,
  WidgetRef ref, {
  required TontineDetail detail,
  required MemberLine line,
  required Day today,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final saved = await showModalBottomSheet<_Saved>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim.withValues(alpha: 0.85),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => PaymentSheet(detail: detail, line: line, today: today),
  );
  if (saved == null) return;
  ref.invalidate(tontineDetailProvider(detail.id));
  ref.invalidate(tontineCardsProvider);
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.text,
      content: Text(
        'Versement de ${formatFcfa(saved.amount)} enregistré pour '
        '${firstName(line.member.name)}',
      ),
      action: SnackBarAction(
        label: 'Annuler',
        textColor: AppColors.primaryPale,
        onPressed: () async {
          await ref
              .read(tontineRepositoryProvider)
              .cancelPayment(saved.paymentId, reason: 'annulé aussitôt');
          ref.invalidate(tontineDetailProvider(detail.id));
          ref.invalidate(tontineCardsProvider);
        },
      ),
    ),
  );
}

class _Saved {
  const _Saved(this.paymentId, this.amount);
  final String paymentId;
  final int amount;
}

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({
    super.key,
    required this.detail,
    required this.line,
    required this.today,
  });

  final TontineDetail detail;
  final MemberLine line;
  final Day today;

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  late int _amount;
  late Day _paidOn;
  var _method = PaymentMethod.cash;

  /// The next digit replaces the pre-filled amount instead of extending it.
  var _fresh = true;
  var _saving = false;

  int get _daily => widget.detail.terms.dailyDue(widget.line.member.halves);

  /// "Jour + retard": everything due now, today included.
  int get _dueNow => -widget.line.standing.balance;

  @override
  void initState() {
    super.initState();
    _amount = _daily;
    _paidOn = widget.today;
  }

  void _key(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      final current = _fresh ? '' : (_amount == 0 ? '' : '$_amount');
      _fresh = false;
      final next = switch (key) {
        '⌫' => current.isEmpty ? '' : current.substring(0, current.length - 1),
        _ => current + key,
      };
      // Nine digits are more than any tontine payment.
      if (next.length > 9) return;
      _amount = next.isEmpty ? 0 : int.parse(next);
    });
  }

  void _shortcut(int amount) => setState(() {
    _amount = amount;
    _fresh = true;
  });

  Future<void> _pickDay() async {
    final terms = widget.detail.terms;
    final first = terms.firstDay.isBefore(widget.today)
        ? terms.firstDay
        : widget.today;
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('fr'),
      initialDate: DateTime(_paidOn.year, _paidOn.month, _paidOn.day),
      firstDate: DateTime(first.year, first.month, first.day),
      // A payment cannot be recorded in the future.
      lastDate: DateTime(
        widget.today.year,
        widget.today.month,
        widget.today.day,
      ),
    );
    if (picked != null) setState(() => _paidOn = Day.fromDateTime(picked));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(tontineRepositoryProvider)
          .addPayment(
            tontineId: widget.detail.id,
            memberId: widget.line.member.id,
            amount: _amount,
            method: _method,
            paidOn: _paidOn,
          );
      // apple-design: haptic on the moment that matters. Not awaited: the
      // sheet must not wait on the vibration.
      unawaited(HapticFeedback.mediumImpact());
      if (mounted) Navigator.of(context).pop(_Saved(id, _amount));
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enregistrement impossible.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.line.member;
    final standing = widget.line.standing;
    final terms = widget.detail.terms;
    final after = _amount == 0
        ? null
        : standingOf(
            terms,
            halves: member.halves,
            paid: member.paid + _amount,
            today: terms.dayNumber(widget.today),
          ).upToDay;
    final statusColor = switch (standing.kind) {
      StandingKind.late => AppColors.onWarningPale,
      StandingKind.ahead => AppColors.onInfoPale,
      StandingKind.upToDate => AppColors.onPrimaryPale,
      StandingKind.toCollect => AppColors.onNeutralPale,
    };
    final isToday = _paidOn == widget.today;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  'Versement de ${member.name}',
                  style: const TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  paymentStatus(standing),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Shortcut(
                  label: 'Le jour · ${formatFcfa(_daily)}',
                  selected: _amount == _daily,
                  onTap: () => _shortcut(_daily),
                ),
                if (standing.kind == StandingKind.late && _dueNow != _daily)
                  _Shortcut(
                    label: 'Jour + retard · ${formatFcfa(_dueNow)}',
                    selected: _amount == _dueNow,
                    onTap: () => _shortcut(_dueNow),
                  ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.controlBorder),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  const Text('Montant reçu', style: AppText.small),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      formatFcfa(_amount),
                      style: AppText.amountLarge,
                    ),
                  ),
                  Text(
                    after == null
                        ? 'Saisissez le montant reçu'
                        : '${firstName(member.name)} sera à jour jusqu’au '
                              'jour $after',
                    style: AppText.small,
                  ),
                ],
              ),
            ),
            MethodSwitch<PaymentMethod>(
              options: const [
                (PaymentMethod.cash, 'Espèces'),
                (PaymentMethod.mobileMoney, 'Mobile money'),
              ],
              method: _method,
              onChanged: (m) => setState(() => _method = m),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                const Flexible(
                  child: Text(
                    'Date du versement',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: AppFonts.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: _pickDay,
                  child: Text(
                    isToday
                        ? 'Aujourd’hui, ${formatDay(_paidOn)}'
                        : formatDay(_paidOn),
                  ),
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 108 / 48,
              children: [
                for (final key in const [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  '000',
                  '0',
                  '⌫', //
                ])
                  _Key(label: key, onTap: () => _key(key)),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _amount > 0 && !_saving ? _save : null,
                    child: Text('Enregistrer ${formatFcfa(_amount)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 40 px rounded shortcut; selected: green border 2 px on pale green.
class _Shortcut extends StatelessWidget {
  const _Shortcut({
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
        color: selected ? AppColors.primaryPale : AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.controlBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          // As wide as its label, not the whole row of the Wrap.
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.onPrimaryPale : AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A key of the keypad: 48 px, radius 12, #F2F4F3, Space Grotesk 20.
class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.keypadKey,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            semanticsLabel: label == '⌫' ? 'Effacer' : label,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
