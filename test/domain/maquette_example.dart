import 'package:matontine/domain/day.dart';
import 'package:matontine/domain/payout.dart';
import 'package:matontine/domain/tontine_terms.dart';

/// The validated mockup's example: 20 places, 5 000 F per place per day,
/// tours of 10 days, starting Thursday 1 October 2026. "Today" is Friday
/// 6 November 2026, day 37, during tour 4.
final exampleTerms = TontineTerms(
  places: 20,
  contributionPerPlace: 5000,
  tourDays: 10,
  firstDay: Day(2026, 10, 1),
);

const exampleToday = 37;

/// Members on day 37, everyone paid today except the three late ones.
///
/// 17 single places plus Mariam's two places and Fatou's half place: the
/// accounts below hold 2 + 2 + 2 + 2 + 4 + 1 + 1 + 13 × 2 = 40 halves.
List<MemberAccount> exampleMembersOnDay37() => [
  // Awa: up to date through day 34, 15 000 F late.
  const MemberAccount(id: 'awa', halves: 2, paid: 34 * 5000),
  // Seydou: up to date through day 28, short on tour 3 already paid out.
  const MemberAccount(id: 'seydou', halves: 2, paid: 28 * 5000),
  // Moussa: up to date through day 33.
  const MemberAccount(id: 'moussa', halves: 2, paid: 33 * 5000),
  const MemberAccount(id: 'koffi', halves: 2, paid: 37 * 5000),
  const MemberAccount(id: 'mariam', halves: 4, paid: 37 * 10000),
  const MemberAccount(id: 'fatou', halves: 1, paid: 37 * 2500),
  const MemberAccount(id: 'aminata', halves: 1, paid: 37 * 2500),
  for (var i = 0; i < 13; i++)
    MemberAccount(id: 'member$i', halves: 2, paid: 37 * 5000),
];
