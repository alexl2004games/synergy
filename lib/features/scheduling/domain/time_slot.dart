class TimeSlot {
  const TimeSlot({required this.startAt, required this.endAt});
  factory TimeSlot.fromStartAndDuration({
    required DateTime startAt,
    required Duration duration,
  }) {
    return TimeSlot(startAt: startAt, endAt: startAt.add(duration));
  }
  final DateTime startAt;
  DateTime get start => startAt;
  final DateTime endAt;
  DateTime get end => endAt;
  Duration get duration => endAt.difference(startAt);
  bool overlaps(TimeSlot other) {
    return startAt.isBefore(other.endAt) && endAt.isAfter(other.startAt);
  }
  bool contains(DateTime value) {
    return !value.isBefore(startAt) && value.isBefore(endAt);
  }
}
