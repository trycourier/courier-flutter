class CourierBackendUrls {
  final String rest;
  final String graphql;
  final String inboxGraphql;
  final String inboxWebSocket;

  const CourierBackendUrls({
    required this.rest,
    required this.graphql,
    required this.inboxGraphql,
    required this.inboxWebSocket,
  });

  Map<String, String> toMap() {
    return {
      'rest': rest,
      'graphql': graphql,
      'inboxGraphql': inboxGraphql,
      'inboxWebSocket': inboxWebSocket,
    };
  }

  static CourierBackendUrls fromMap(Map<String, dynamic> map) {
    return CourierBackendUrls(
      rest: map['rest'] as String,
      graphql: map['graphql'] as String,
      inboxGraphql: map['inboxGraphql'] as String,
      inboxWebSocket: map['inboxWebSocket'] as String,
    );
  }
}
