import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'format.dart';
import 'theme.dart';

/// Back arrow and 17 px title: header of "Nouvelle tontine" and "Remise de
/// la cagnotte" (padding 12 8 4, 44 px arrow, 4 px gap).
class BackHeader extends StatelessWidget {
  const BackHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        spacing: 4,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              tooltip: 'Retour',
              padding: EdgeInsets.zero,
              color: AppColors.text,
              icon: const Icon(Icons.chevron_left, size: 26),
              onPressed: onBack,
            ),
          ),
          Text(title, style: AppText.appBarTitle),
        ],
      ),
    );
  }
}

/// The four bars of "Nouvelle tontine": done and current bars are green, the
/// current label is bold green.
class CreationSteps extends StatelessWidget {
  const CreationSteps({super.key, required this.current});

  /// 1 to 4.
  final int current;

  static const _labels = ['Paramètres', 'Membres', 'Ordre', 'Récap'];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Étape $current sur 4',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          spacing: 6,
          children: [
            for (final (i, label) in _labels.indexed)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < current
                            ? AppColors.primary
                            : AppColors.stepInactive,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      '${i + 1} · $label',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: i + 1 == current
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: i + 1 == current
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// White field with its 12 px label above the value (padding 8 14, border
/// #DCE2DE, radius 12), as in "Nouvelle tontine · paramètres".
class LabeledBox extends StatelessWidget {
  const LabeledBox({
    super.key,
    required this.label,
    required this.child,
    this.helper,
    this.helperIsWarning = false,
    this.onTap,
  });

  final String label;
  final Widget child;
  final String? helper;
  final bool helperIsWarning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.controlBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(label, style: AppText.small),
              child,
              if (helper != null)
                Text(
                  helper!,
                  style: AppText.small.copyWith(
                    color: helperIsWarning
                        ? AppColors.onWarningPale
                        : AppColors.textSecondary,
                    fontWeight: helperIsWarning
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Value style of a [LabeledBox]: 600 16 px.
const fieldValueStyle = TextStyle(
  fontFamily: AppFonts.text,
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.text,
);

/// A borderless text input for a [LabeledBox], with an optional unit right
/// after the value ("10 jours", "5 000 F").
class BareInput extends StatelessWidget {
  const BareInput({
    super.key,
    required this.controller,
    this.unit,
    this.numeric = false,
    this.groupThousands = false,
    this.hint,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String? unit;
  final bool numeric;
  final bool groupThousands;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      style: fieldValueStyle,
      textCapitalization: textCapitalization,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        if (numeric) FilteringTextInputFormatter.digitsOnly,
        if (groupThousands) const ThousandsFormatter(),
      ],
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        hintText: hint,
        hintStyle: fieldValueStyle.copyWith(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
    if (unit == null) return field;
    return Row(
      children: [
        IntrinsicWidth(child: field),
        Text(' $unit', style: fieldValueStyle),
      ],
    );
  }
}

/// Groups digits by thousands while typing: "5000" shows "5 000".
class ThousandsFormatter extends TextInputFormatter {
  const ThousandsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = formatNumber(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Integer value of a field formatted by [ThousandsFormatter], or `null`.
int? parseAmount(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  return digits.isEmpty ? null : int.tryParse(digits);
}

/// The 12 px rounded badges ("Retard 15 000 F", "Terminée", "3 en retard").
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: AppText.badge.copyWith(color: foreground)),
    );
  }
}

/// The green check line of "Ordre des tours" (radius 10, padding 8 12, 13
/// px 600). In warning colors when something is missing.
class CheckBanner extends StatelessWidget {
  const CheckBanner({super.key, required this.text, required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final foreground = ok ? AppColors.onPrimaryPale : AppColors.onWarningPale;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ok ? AppColors.primaryPale : AppColors.warningPale,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(
            ok ? Icons.check : Icons.error_outline,
            size: 16,
            color: foreground,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small outlined action next to a section title ("Tirer au sort"): 40 px
/// high, padding 0 12, radius 12, 600 13 px, 16 px icon.
class SmallAction extends StatelessWidget {
  const SmallAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(
          fontFamily: AppFonts.text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Section title of 20 px ("Qui ramasse quand ?").
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

/// The 54 px green button at the bottom of a screen, 16 px around.
class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

/// A white list row as in "Ordre des tours" (radius 12, border #E3E7E4).
class RowCard extends StatelessWidget {
  const RowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 4, 8),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The 36 px avatar with initials of "Aujourd'hui".
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.name, {super.key, this.size = 36});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primaryPale,
          shape: BoxShape.circle,
        ),
        child: Text(
          initialsOf(name),
          style: TextStyle(
            fontSize: size == 36 ? 13 : 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
