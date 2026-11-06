import 'package:courier_flutter/courier_backend_urls.dart';

import 'env.dart';

class CourierEnvironment {
  final String label;
  final CourierBackendUrls? urls;

  const CourierEnvironment(this.label, this.urls);

  static const production = CourierEnvironment(
    'Production',
    CourierBackendUrls(
      rest: 'https://api.courier.com',
      graphql: 'https://api.courier.com/client/q',
      inboxGraphql: 'https://inbox.courier.com/q',
      inboxWebSocket: 'wss://realtime.courier.io',
    ),
  );

  static const productionEu = CourierEnvironment(
    'Production EU',
    CourierBackendUrls(
      rest: 'https://api.eu.courier.com',
      graphql: 'https://api.eu.courier.com/client/q',
      inboxGraphql: 'https://inbox.eu.courier.io/q',
      inboxWebSocket: 'wss://realtime.eu.courier.io',
    ),
  );

  static const custom = CourierEnvironment('Custom', null);

  /// The picker's options. Extra environments for local builds come from `Env.localEnvironments`
  /// in the gitignored env.dart, and are listed between Production EU and Custom:
  ///
  /// ```dart
  /// static const localEnvironments = [
  ///   CourierEnvironment('My Environment', CourierBackendUrls(
  ///     rest: 'https://…', graphql: 'https://…/client/q',
  ///     inboxGraphql: 'https://…/q', inboxWebSocket: 'wss://…',
  ///   )),
  /// ];
  /// ```
  static List<CourierEnvironment> get values => [
        production,
        productionEu,
        ...Env.localEnvironments,
        custom,
      ];

  static const CourierBackendUrls defaultUrls = CourierBackendUrls(
    rest: 'https://api.courier.com',
    graphql: 'https://api.courier.com/client/q',
    inboxGraphql: 'https://inbox.courier.com/q',
    inboxWebSocket: 'wss://realtime.courier.io',
  );

  // A saved environment this build doesn't define keeps its saved URLs, so it shows as Custom
  static CourierEnvironment fromLabel(String label) {
    return values.firstWhere(
      (e) => e.label == label,
      orElse: () => custom,
    );
  }
}
