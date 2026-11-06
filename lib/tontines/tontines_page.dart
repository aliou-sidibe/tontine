import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../common/theme.dart';

/// "Mes tontines" (mockup board "Mes tontines"). Step 1 shows the empty
/// state; the tontine cards come with step 2.
class TontinesPage extends ConsumerWidget {
  const TontinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Text('EN COURS', style: AppText.sectionLabel),
                    _EmptyCard(),
                  ],
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
                    // Wired in step 2 (création de tontine).
                    onPressed: null,
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
                          onPressed: () => _showAccount(context, ref),
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

  void _showAccount(BuildContext context, WidgetRef ref) {
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
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
      ),
    );
  }
}
