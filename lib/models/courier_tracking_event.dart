enum CourierTrackingEvent {
  clicked("CLICKED"),
  delivered("DELIVERED"),
  opened("OPENED"),
  read("READ"),
  unread("UNREAD");

  final String value;

  const CourierTrackingEvent(this.value);

  @override
  String toString() => value;

  static CourierTrackingEvent fromValue(String value) {
    return CourierTrackingEvent.values.firstWhere((e) => e.value == value,
        orElse: () => throw ArgumentError('Invalid value: $value'));
  }
}
