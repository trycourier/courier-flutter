enum InboxFeed {
  feed("feed"),
  archive("archive");

  final String value;

  const InboxFeed(this.value);

  @override
  String toString() => value;

  static InboxFeed fromValue(String value) {
    return InboxFeed.values.firstWhere((e) => e.value == value,
        orElse: () => throw ArgumentError('Invalid value: $value'));
  }
}
