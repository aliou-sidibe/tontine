/// A calendar day, without time of day or time zone.
///
/// Contribution days and payout days are whole days: the phone's clock time
/// must never shift a day. Arithmetic goes through UTC so that daylight
/// saving changes cannot add or remove a day.
class Day implements Comparable<Day> {
  Day(int year, int month, int day) : _utc = DateTime.utc(year, month, day);

  Day._(this._utc);

  /// The local calendar day of [moment].
  factory Day.fromDateTime(DateTime moment) =>
      Day(moment.year, moment.month, moment.day);

  /// Parses `yyyy-mm-dd`, the storage format.
  factory Day.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) throw FormatException('Invalid day: $iso');
    return Day(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  final DateTime _utc;

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  /// 1 = Monday … 7 = Sunday.
  int get weekday => _utc.weekday;

  Day addDays(int days) => Day._(_utc.add(Duration(days: days)));

  /// Number of days from this day to [other] (negative if [other] is before).
  int daysUntil(Day other) => other._utc.difference(_utc).inDays;

  bool isBefore(Day other) => _utc.isBefore(other._utc);
  bool isAfter(Day other) => _utc.isAfter(other._utc);

  /// `yyyy-mm-dd`, sortable as text.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(Day other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) => other is Day && other._utc == _utc;

  @override
  int get hashCode => _utc.hashCode;

  @override
  String toString() => toIso();
}
