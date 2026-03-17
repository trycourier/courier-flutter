enum CourierApiRegion { us, eu }

class CourierApiUrls {
  final String rest;
  final String graphql;
  final String inboxGraphql;
  final String inboxWebSocket;

  const CourierApiUrls({
    this.rest = 'https://api.courier.com',
    this.graphql = 'https://api.courier.com/client/q',
    this.inboxGraphql = 'https://inbox.courier.io/q',
    this.inboxWebSocket = 'wss://realtime.courier.io',
  });

  const CourierApiUrls.us()
      : rest = 'https://api.courier.com',
        graphql = 'https://api.courier.com/client/q',
        inboxGraphql = 'https://inbox.courier.io/q',
        inboxWebSocket = 'wss://realtime.courier.io';

  const CourierApiUrls.eu()
      : rest = 'https://api.eu.courier.com',
        graphql = 'https://api.eu.courier.com/client/q',
        inboxGraphql = 'https://inbox.eu.courier.io/q',
        inboxWebSocket = 'wss://realtime.eu.courier.io';

  factory CourierApiUrls.forRegion(CourierApiRegion region) {
    return region == CourierApiRegion.eu
        ? const CourierApiUrls.eu()
        : const CourierApiUrls.us();
  }

  factory CourierApiUrls.fromJson(Map<dynamic, dynamic> json) {
    return CourierApiUrls(
      rest: json['rest'] as String? ?? const CourierApiUrls().rest,
      graphql: json['graphql'] as String? ?? const CourierApiUrls().graphql,
      inboxGraphql:
          json['inboxGraphql'] as String? ?? const CourierApiUrls().inboxGraphql,
      inboxWebSocket: json['inboxWebSocket'] as String? ??
          const CourierApiUrls().inboxWebSocket,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rest': rest,
      'graphql': graphql,
      'inboxGraphql': inboxGraphql,
      'inboxWebSocket': inboxWebSocket,
    };
  }
}
