import 'package:courier_flutter/courier_backend_urls.dart';
import 'package:courier_flutter_sample/courier_environment.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static const _keyUserId = 'user_id';
  static const _keyTenantId = 'tenant_id';
  static const _keyApiKey = 'api_key';
  static const _keyEnvironment = 'environment';
  static const _keyRestUrl = 'rest_url';
  static const _keyGraphqlUrl = 'graphql_url';
  static const _keyInboxGraphqlUrl = 'inbox_graphql_url';
  static const _keyInboxWebSocketUrl = 'inbox_websocket_url';

  final SharedPreferences _prefs;

  AuthPreferences(this._prefs);

  static Future<AuthPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthPreferences(prefs);
  }

  String? get userId => _prefs.getString(_keyUserId);
  set userId(String? value) => _setOrRemove(_keyUserId, value);

  String? get tenantId => _prefs.getString(_keyTenantId);
  set tenantId(String? value) => _setOrRemove(_keyTenantId, value);

  String get apiKey => _prefs.getString(_keyApiKey) ?? Env.authKey;
  set apiKey(String? value) => _setOrRemove(_keyApiKey, value);

  String? get environment => _prefs.getString(_keyEnvironment);
  set environment(String? value) => _setOrRemove(_keyEnvironment, value);

  String? get restUrl => _prefs.getString(_keyRestUrl);
  set restUrl(String? value) => _setOrRemove(_keyRestUrl, value);

  String? get graphqlUrl => _prefs.getString(_keyGraphqlUrl);
  set graphqlUrl(String? value) => _setOrRemove(_keyGraphqlUrl, value);

  String? get inboxGraphqlUrl => _prefs.getString(_keyInboxGraphqlUrl);
  set inboxGraphqlUrl(String? value) => _setOrRemove(_keyInboxGraphqlUrl, value);

  String? get inboxWebSocketUrl => _prefs.getString(_keyInboxWebSocketUrl);
  set inboxWebSocketUrl(String? value) => _setOrRemove(_keyInboxWebSocketUrl, value);

  void saveApiUrls(CourierBackendUrls urls) {
    restUrl = urls.rest;
    graphqlUrl = urls.graphql;
    inboxGraphqlUrl = urls.inboxGraphql;
    inboxWebSocketUrl = urls.inboxWebSocket;
  }

  CourierBackendUrls getApiUrls() {
    const defaults = CourierEnvironment.defaultUrls;
    return CourierBackendUrls(
      rest: restUrl ?? defaults.rest,
      graphql: graphqlUrl ?? defaults.graphql,
      inboxGraphql: inboxGraphqlUrl ?? defaults.inboxGraphql,
      inboxWebSocket: inboxWebSocketUrl ?? defaults.inboxWebSocket,
    );
  }

  void _setOrRemove(String key, String? value) {
    if (value == null || value.isEmpty) {
      _prefs.remove(key);
    } else {
      _prefs.setString(key, value);
    }
  }
}
