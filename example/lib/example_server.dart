import 'dart:convert';
import 'package:http/http.dart' as http;

class ExampleServer {

  static Future<String> generateJwt({required String authKey, required String userId}) async {
    const url = 'https://api.courier.com/auth/issue-token';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authKey',
    };

    final body = jsonEncode({
      'scope': 'user_id:$userId write:user-tokens inbox:read:messages inbox:write:events read:preferences write:preferences read:brands',
      'expires_in': '2 days',
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception('Failed to generate token: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to generate token: $error');
    }
  }

}