enum CourierUserPreferencesChannel {

  directMessage(value: "direct_message"),
  email(value: "email"),
  push(value: "push"),
  sms(value: "sms"),
  webhook(value: "webhook"),
  unknown(value: "unknown");

  final String value;

  const CourierUserPreferencesChannel({
    required this.value,
  });

  factory CourierUserPreferencesChannel.fromJson(dynamic data) {
    switch (data) {
      case 'direct_message':
        return CourierUserPreferencesChannel.directMessage;
      case 'email':
        return CourierUserPreferencesChannel.email;
      case 'push':
        return CourierUserPreferencesChannel.push;
      case 'sms':
        return CourierUserPreferencesChannel.sms;
      case 'webhook':
        return CourierUserPreferencesChannel.webhook;
      default:
        return CourierUserPreferencesChannel.unknown;
    }
  }

}