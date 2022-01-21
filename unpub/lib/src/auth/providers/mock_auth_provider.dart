import 'dart:convert';

import 'package:unpub/src/auth/providers/auth_provider.dart';
import 'package:unpub/src/auth/models/auth_result.dart';

class MockAuthProvider extends AuthProvider {
  MockAuthProvider([String? proxy]) : super(proxy);

  @override
  Future<AuthResult?> tryAuthenticate(String token) async {
    final tokenData =
        jsonDecode(utf8.decode(base64.decode(token))) as Map<String, dynamic>;

    final userId = tokenData['user_id'] as String?;
    final email = tokenData['email'] as String?;
    final scopes = (tokenData['scope'] as String?)?.split(' ') ?? [];

    if (userId == null || email == null) {
      return null;
    }

    return AuthResult(userId, email, scopes);
  }
}
