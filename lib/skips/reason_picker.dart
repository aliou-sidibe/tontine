import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/theme.dart';
import 'skip_texts.dart';

/// "Motif (facultatif)": three common reasons, or another typed in.
class ReasonPicker extends StatefulWidget {
  const ReasonPicker({super.key, required this.onChanged});

  /// The reason, or null when none is given.
  final ValueChanged<String?> onChanged;

  static const reasons = ['Fête', 'Marché fermé', 'Imprévu'];

  @override
  State<ReasonPicker> createState() => _ReasonPickerState();
}

class _ReasonPickerState extends State<ReasonPicker> {
  final _other = TextEditingController();
  String? _chosen;

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  void _pick(String reason) {
    HapticFeedback.selectionClick();
    setState(() {
      _chosen = _chosen == reason ? null : reason;
      if (_chosen != null) _other.clear();
    });
    widget.onChanged(_chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        const Text(
          'Motif (facultatif)',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final reason in ReasonPicker.reasons)
              _ReasonChip(
                label: reason,
                selected: _chosen == reason,
                onTap: () => _pick(reason),
              ),
          ],
        ),
        TextField(
          controller: _other,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 15, color: AppColors.text),
          decoration: const InputDecoration(hintText: 'Autre motif…'),
          onChanged: (text) {
            if (_chosen != null) setState(() => _chosen = null);
            widget.onChanged(text.trim().isEmpty ? null : text.trim());
          },
        ),
      ],
    );
  }
}

/// A reason chip: 36 px, radius 18; chosen in pale green with a 2 px border.
class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
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
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.primaryPale : AppColors.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.controlBorder,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
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
                color: selected ? AppColors.onPrimaryPale : AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The grey box that tells what a skip changes.
class EffectBox extends StatelessWidget {
  const EffectBox({
    super.key,
    required this.title,
    required this.lines,
    this.note,
  });

  final String title;
  final List<EffectLine> lines;
  final String? note;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13, color: AppColors.onNeutralPale);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutralPale,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Text(title, style: style.copyWith(fontWeight: FontWeight.w600)),
          for (final line in lines)
            Text.rich(
              TextSpan(
                text: line.before,
                children: [
                  TextSpan(
                    text: line.strong,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: line.after),
                ],
              ),
              style: style,
            ),
          if (note != null) Text(note!, style: AppText.small),
        ],
      ),
    );
  }
}
