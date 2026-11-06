import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/format.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../domain/draft.dart';
import 'creation_state.dart';

/// Bottom sheet to add or edit a member. Not in the mockup: it follows the
/// "Versement" sheet (handle, 22 px title, Annuler + main button).
Future<void> showMemberSheet(
  BuildContext context, {
  required int contribution,
  DraftMember? member,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim.withValues(alpha: 0.85),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _MemberSheet(contribution: contribution, member: member),
  );
}

class _MemberSheet extends ConsumerStatefulWidget {
  const _MemberSheet({required this.contribution, this.member});

  final int contribution;
  final DraftMember? member;

  @override
  ConsumerState<_MemberSheet> createState() => _MemberSheetState();
}

class _MemberSheetState extends ConsumerState<_MemberSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late int _halves;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.member?.name ?? '');
    _phone = TextEditingController(text: widget.member?.phone ?? '');
    _halves = widget.member?.halves ?? 2;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    final notifier = ref.read(creationProvider.notifier);
    final phone = _phone.text.trim().isEmpty ? null : _phone.text.trim();
    final member = widget.member;
    if (member == null) {
      notifier.addMember(name: _name.text, phone: phone, halves: _halves);
    } else {
      notifier.updateMember(
        member.key,
        name: _name.text,
        phone: phone,
        halves: _halves,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.member != null;
    final canSave = _name.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
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
              Text(
                editing ? 'Modifier le membre' : 'Nouveau membre',
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              LabeledBox(
                label: 'Nom',
                child: BareInput(
                  controller: _name,
                  hint: 'Awa Koné',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              LabeledBox(
                label: 'Téléphone (facultatif)',
                child: BareInput(
                  controller: _phone,
                  numeric: true,
                  hint: '07 00 00 00 00',
                ),
              ),
              _PlacesStepper(
                halves: _halves,
                contribution: widget.contribution,
                onChanged: (h) => setState(() => _halves = h),
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
                      onPressed: canSave ? _save : null,
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
              if (editing)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onWarningPale,
                  ),
                  onPressed: () {
                    ref
                        .read(creationProvider.notifier)
                        .removeMember(widget.member!.key);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Retirer ce membre',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Places by steps of ½, with the daily contribution it means.
class _PlacesStepper extends StatelessWidget {
  const _PlacesStepper({
    required this.halves,
    required this.contribution,
    required this.onChanged,
  });

  final int halves;
  final int contribution;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final daily = halves * contribution ~/ 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.controlBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                const Text('Places', style: AppText.small),
                Text(formatPlaces(halves), style: fieldValueStyle),
                Text('${formatFcfa(daily)} par jour', style: AppText.small),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.remove,
            tooltip: 'Une demi-place de moins',
            onPressed: halves > 1 ? () => onChanged(halves - 1) : null,
          ),
          const SizedBox(width: 8),
          _StepButton(
            icon: Icons.add,
            tooltip: 'Une demi-place de plus',
            onPressed: () => onChanged(halves + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton.filled(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.keypadKey,
          foregroundColor: AppColors.text,
          disabledBackgroundColor: AppColors.keypadKey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
