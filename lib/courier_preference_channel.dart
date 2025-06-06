enum CourierUserPreferencesChannel {

  directMessage(value: "direct_message"),
  inbox(value: "inbox"),
  email(value: "email"),
  push(value: "push"),
  sms(value: "sms"),
  webhook(value: "webhook"),
  unknown(value: "unknown");

  final String value;

  const CourierUserPreferencesChannel({required this.value});

  factory CourierUserPreferencesChannel.fromJson(dynamic data) {
    switch (data) {
      case 'direct_message':
        return CourierUserPreferencesChannel.directMessage;
      case 'inbox':
        return CourierUserPreferencesChannel.inbox;
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

  String get title {
    switch (this) {
      case CourierUserPreferencesChannel.directMessage:
        return 'In App Messages';
      case CourierUserPreferencesChannel.inbox:
        return 'Inbox';
      case CourierUserPreferencesChannel.email:
        return 'Emails';
      case CourierUserPreferencesChannel.push:
        return 'Push Notifications';
      case CourierUserPreferencesChannel.sms:
        return 'Text Messages';
      case CourierUserPreferencesChannel.webhook:
        return 'Webhooks';
      case CourierUserPreferencesChannel.unknown:
        return 'Unknown';
    }
  }

  static List<CourierUserPreferencesChannel> get allCases => [
    CourierUserPreferencesChannel.push,
    CourierUserPreferencesChannel.inbox,
    CourierUserPreferencesChannel.sms,
    CourierUserPreferencesChannel.email,
    CourierUserPreferencesChannel.directMessage,
    CourierUserPreferencesChannel.webhook,
  ];

}