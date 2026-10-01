import 'package:courier_flutter/courier_flutter.dart';

class InboxAction {

  final String? content;
  final String? href;
  final dynamic data;

  InboxAction({
    this.content,
    this.href,
    this.data,
  });

  /// The id Courier uses to attribute a click to this action.
  ///
  /// It travels on the action rather than on the message, so a click is recorded against the
  /// button the user actually pressed. A template that opts out of tracking arrives without one.
  String? get trackingId {
    final value = data is Map ? data['trackingId'] : null;
    return value is String && value.isNotEmpty ? value : null;
  }

  /// Report a click on this action.
  ///
  /// [CourierInbox] does this for you when an action is pressed. Call it yourself when you build
  /// your own action buttons. A no-op when the action carries no tracking id.
  Future markAsClicked(String messageId) async {
    final id = trackingId;
    if (id == null) {
      return;
    }
    return Courier.shared.clickMessageAction(messageId: messageId, trackingId: id);
  }

}
