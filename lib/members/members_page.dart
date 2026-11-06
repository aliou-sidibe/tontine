import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/theme.dart';
import '../data/tontine_repository.dart';
import '../today/today_page.dart';
import '../today/today_texts.dart';
import 'member_page.dart';

/// "Membres" tab. Not in the mockup: the header of "Aujourd'hui" and its
/// rows, sorted by name; a tap opens the member page.
class MembersPage extends ConsumerWidget {
  const MembersPage({super.key, required this.tontineId});

  final String tontineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(tontineDetailProvider(tontineId));
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text('Lecture impossible : $error')),
        data: (detail) {
          final view = detail.today(today);
          final lines = [...view.lines]
            ..sort(
              (a, b) => a.member.name.toLowerCase().compareTo(
                b.member.name.toLowerCase(),
              ),
            );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(detail.name, style: AppText.caption),
                    const Text('Membres', style: AppText.screenTitle),
                    Text(
                      '${lines.length} membre${lines.length > 1 ? 's' : ''} · '
                      '${detail.terms.places} places',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: lines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => MemberRowTile(
                    line: lines[i],
                    subtitle: rowSubtitle(
                      lines[i],
                      detail.terms,
                      view.payoutDay,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MemberPage(
                          tontineId: tontineId,
                          memberId: lines[i].member.id,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
