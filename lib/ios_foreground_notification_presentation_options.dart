enum iOSNotificationPresentationOption {

  sound(value: "sound"),
  list(value: "list"),
  banner(value: "banner"),
  badge(value: "badge");

  final String value;

  const iOSNotificationPresentationOption({
    required this.value,
  });

}