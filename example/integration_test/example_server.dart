import 'dart:convert';
import 'package:http/http.dart' as http;

class ExampleServer {
  static Future<String> generateJwt(String authKey, String userId) async {
    final url = Uri.parse('https://api.courier.com/auth/issue-token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authKey',
    };
    final body = jsonEncode({
      'scope': 'user_id:$userId write:user-tokens inbox:read:messages inbox:write:events read:preferences write:preferences read:brands',
      'expires_in': '2 days',
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['token'];
    } else {
      throw Exception('Failed to generate JWT');
    }
  }

  static Future<String> sendTest(String authKey, String userId, String channel) async {
    final url = Uri.parse('https://api.courier.com/send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authKey',
    };
    final body = jsonEncode({
      'message': {
        'to': {'user_id': userId},
        'content': {
          'title': 'Test',
          'body': 'Body',
        },
        'routing': {
          'method': 'all',
          'channels': [channel],
        },
      },
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 202) {
      final json = jsonDecode(response.body);
      return json['requestId'] ?? 'Error';
    } else {
      throw Exception('Failed to send test message');
    }
  }
}