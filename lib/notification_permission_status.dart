enum NotificationPermissionStatus {

  notDetermined(value: "notDetermined"),
  denied(value: "denied"),
  authorized(value: "authorized"),
  provisional(value: "provisional"),
  ephemeral(value: "ephemeral"),
  unknown(value: "unknown");

  final String value;

  const NotificationPermissionStatus({
    required this.value,
  });

}

extension NotificationPermissionStatusExt on String {

  NotificationPermissionStatus get permissionStatus {
    try {
      return NotificationPermissionStatus.values.firstWhere((state) => state.value == this);
    } catch (error) {
      return NotificationPermissionStatus.unknown;
    }
  }

}