import 'package:courier_flutter/courier_backend_urls.dart';

enum CourierEnvironment {
  production('Production'),
  productionEu('Production EU'),
  staging('Staging'),
  dev('Dev'),
  custom('Custom');

  final String label;
  const CourierEnvironment(this.label);

  CourierBackendUrls? get urls {
    switch (this) {
      case CourierEnvironment.production:
        return const CourierBackendUrls(
          rest: 'https://api.courier.com',
          graphql: 'https://api.courier.com/client/q',
          inboxGraphql: 'https://inbox.courier.com/q',
          inboxWebSocket: 'wss://realtime.courier.io',
        );
      case CourierEnvironment.productionEu:
        return const CourierBackendUrls(
          rest: 'https://api.eu.courier.com',
          graphql: 'https://api.eu.courier.com/client/q',
          inboxGraphql: 'https://inbox.eu.courier.io/q',
          inboxWebSocket: 'wss://realtime.eu.courier.io',
        );
      case CourierEnvironment.staging:
        return const CourierBackendUrls(
          rest: 'https://api.courierstaging.com',
          graphql: 'https://api.courierstaging.com/client/q',
          inboxGraphql: 'http://inbox.courierstaging.com/',
          inboxWebSocket: 'wss://inbox-staging-ws-alb-490231599.us-east-1.elb.amazonaws.com',
        );
      case CourierEnvironment.dev:
        return const CourierBackendUrls(
          rest: 'https://api.courierdev.com',
          graphql: 'https://api.courierdev.com/client/q',
          inboxGraphql: 'https://inbox.courierdev.com/q',
          inboxWebSocket: 'wss://9mrugsdnk1.execute-api.us-east-1.amazonaws.com/dev',
        );
      case CourierEnvironment.custom:
        return null;
    }
  }

  static const CourierBackendUrls defaultUrls = CourierBackendUrls(
    rest: 'https://api.courier.com',
    graphql: 'https://api.courier.com/client/q',
    inboxGraphql: 'https://inbox.courier.com/q',
    inboxWebSocket: 'wss://realtime.courier.io',
  );

  static CourierEnvironment fromLabel(String label) {
    return CourierEnvironment.values.firstWhere(
      (e) => e.label == label,
      orElse: () => CourierEnvironment.production,
    );
  }
}
