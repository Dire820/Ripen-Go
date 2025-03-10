import 'package:http/http.dart' as http;
import 'dart:convert';

class MySQLAuthService {
  static Map<String, dynamic>? userData;

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(
        'http://localhost/ripen_go/backend/login.php',
      ), // Update the URL to point to your backend
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      try {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          return responseBody['data'];
        } else {
          return {'error': responseBody['message']};
        }
      } catch (e) {
        print("Response body is not valid JSON: ${response.body}");
        return {'error': 'Invalid response from server'};
      }
    } else {
      return {'error': 'Error: ${response.reasonPhrase}'};
    }
  }
}
