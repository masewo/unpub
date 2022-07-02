import 'package:unpub/src/auth/models/auth_result.dart';
import 'package:unpub/src/auth/providers/auth_provider.dart';
import 'package:unpub/src/auth/user_store.dart';

class TokenAuthProvider extends AuthProvider {
  TokenAuthProvider(UserStore userStore) : super(userStore);

  @override
  Future<AuthResult?> tryAuthenticate(String token) async {
    final user = await userStore.findByToken(token);

    if (user == null) {
      return null;
    }

    final scopes = await userStore.getTokenScopes(user.id, token);

    if (scopes == null) {
      return null;
    }

    return AuthResult(user.id, user.email, scopes);
  }
}
