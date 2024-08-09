enum iOSNotificationPresentationOption {

  sound(value: "sound"),
  list(value: "list"),
  banner(value: "banner"),
  badge(value: "badge");

  final String value;

  const iOSNotificationPresentationOption({
    required this.value,
  });

  static iOSNotificationPresentationOption fromString(String value) {
    return iOSNotificationPresentationOption.values.firstWhere((option) => option.value == value);
  }

}