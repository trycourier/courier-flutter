import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/models/courier_tracking_event.dart';

class TrackingClient {
  final CourierClientOptions _options;

  TrackingClient(this._options);

  Future postTrackingUrl({required String url, required CourierTrackingEvent event}) async {
    await _options.invokeClient('client.tracking.post_tracking_url', {
      'url': url,
      'event': event.value,
    });
  }

}