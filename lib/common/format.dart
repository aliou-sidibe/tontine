import '../domain/day.dart';

/// Non-breaking space: an amount never wraps between its digits and "F".
const _nbsp = ' ';

/// Groups thousands: `4500` becomes `4 500`.
String formatNumber(int number) {
  final digits = number.abs().toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(_nbsp);
    grouped.write(digits[i]);
  }
  return '${number < 0 ? '-' : ''}$grouped';
}

/// An amount in FCFA, as in the mockup: `5000` becomes `5 000 F`.
String formatFcfa(int amount) => '${formatNumber(amount)}${_nbsp}F';

const _weekdays = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
const _months = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

/// `mar. 10 nov.`, or `mar. 10 nov. 2026` with [withYear].
String formatDay(Day day, {bool withYear = false}) {
  final text =
      '${_weekdays[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}';
  return withYear ? '$text ${day.year}' : text;
}

/// `10 nov.`: without the weekday, as in "ramasse le 10 nov.".
String formatDayShort(Day day) => '${day.day} ${_months[day.month - 1]}';

/// `1 place`, `2 places`, `½ place`, `1 place ½`.
String formatPlaces(int halves) {
  final whole = halves ~/ 2;
  final half = halves.isOdd;
  if (whole == 0) return '½ place';
  final noun = whole > 1 ? 'places' : 'place';
  return half ? '$whole $noun ½' : '$whole $noun';
}

/// Initials shown in the avatar circle: "Awa Koné" gives "AK".
String initialsOf(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  String firstLetter(String word) => String.fromCharCode(word.runes.first);
  final last = words.length > 1 ? firstLetter(words.last) : '';
  return (firstLetter(words.first) + last).toUpperCase();
}
