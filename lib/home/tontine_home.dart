import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/theme.dart';
import '../members/members_page.dart';
import '../today/today_page.dart';
import '../tours/tours_page.dart';

/// One tontine, with the bottom bar of the mockup: Aujourd'hui, Membres,
/// Tours, Plus. "Plus" goes back to "Mes tontines". Each tab keeps its own
/// navigation, so the member page opens under the "Membres" tab.
class TontineHome extends StatefulWidget {
  const TontineHome({super.key, required this.tontineId});

  final String tontineId;

  @override
  State<TontineHome> createState() => _TontineHomeState();
}

class _TontineHomeState extends State<TontineHome> {
  var _tab = 0;
  final _navigators = List.generate(3, (_) => GlobalKey<NavigatorState>());

  void _select(int tab) {
    if (tab == 3) {
      Navigator.of(context).pop();
      return;
    }
    HapticFeedback.selectionClick();
    if (tab == _tab) {
      // A second tap on the current tab goes back to its first screen.
      _navigators[tab].currentState?.popUntil((r) => r.isFirst);
    }
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TodayPage(tontineId: widget.tontineId),
      MembersPage(tontineId: widget.tontineId),
      ToursPage(tontineId: widget.tontineId),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final inner = _navigators[_tab].currentState;
        if (inner != null && await inner.maybePop()) return;
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _tab,
            children: [
              for (final (i, page) in pages.indexed)
                Navigator(
                  key: _navigators[i],
                  onGenerateRoute: (_) =>
                      MaterialPageRoute<void>(builder: (_) => page),
                ),
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(current: _tab, onSelect: _select),
      ),
    );
  }
}

/// The mockup's bottom bar: 64 px, white, top border, 22 px icons, 11 px
/// labels; active in green 600, others grey 500.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.current, required this.onSelect});

  final int current;
  final ValueChanged<int> onSelect;

  static const _items = [
    (Icons.calendar_today_outlined, 'Aujourd\'hui'),
    (Icons.group_outlined, 'Membres'),
    (Icons.refresh, 'Tours'),
    (Icons.more_horiz, 'Plus'),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Navigation principale',
      container: true,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (final (i, (icon, label)) in _items.indexed)
                  Expanded(
                    child: InkResponse(
                      onTap: () => onSelect(i),
                      containedInkWell: true,
                      child: Semantics(
                        selected: i == current,
                        button: true,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 2,
                          children: [
                            Icon(
                              icon,
                              size: 22,
                              color: i == current
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: i == current
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: i == current
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
