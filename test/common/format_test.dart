import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/common/format.dart';
import 'package:matontine/domain/day.dart';

/// The mockup writes amounts with spaces; the app uses non-breaking ones.
String nb(String text) => text.replaceAll(' ', ' ');

void main() {
  test('amounts as in the mockup', () {
    expect(formatFcfa(5000), nb('5 000 F'));
    expect(formatFcfa(1000000), nb('1 000 000 F'));
    expect(formatFcfa(995000), nb('995 000 F'));
    expect(formatFcfa(0), nb('0 F'));
  });

  test('days as in the mockup', () {
    expect(formatDay(Day(2026, 11, 6)), 'ven. 6 nov.');
    expect(formatDay(Day(2026, 11, 10)), 'mar. 10 nov.');
    expect(formatDay(Day(2026, 10, 1), withYear: true), 'jeu. 1 oct. 2026');
    expect(formatDay(Day(2027, 1, 29), withYear: true), 'ven. 29 janv. 2027');
    expect(formatDay(Day(2027, 4, 19), withYear: true), 'lun. 19 avr. 2027');
  });

  test('places as in the mockup', () {
    expect(formatPlaces(2), '1 place');
    expect(formatPlaces(4), '2 places');
    expect(formatPlaces(1), '½ place');
    expect(formatPlaces(3), '1 place ½');
  });

  test('initials', () {
    expect(initialsOf('Awa Koné'), 'AK');
    expect(initialsOf('Adjoua N’Guessan'), 'AN');
    expect(initialsOf('  mariam  '), 'M');
    expect(initialsOf('Élise Yao'), 'ÉY');
  });
}
