import 'package:googleapis/oauth2/v2.dart';
import 'package:unpub/src/auth/providers/auth_provider.dart';
import 'package:unpub/src/auth/models/auth_result.dart';
import 'package:unpub/src/auth/providers/google/google_auth_config.dart';
import 'package:unpub/src/auth/user_store.dart';

class GoogleAuthProvider extends AuthProvider {
  final GoogleAuthConfig _config;

  GoogleAuthProvider(this._config, UserStore userStore, [String? proxy]) : super(userStore, proxy);

  @override
  Future<AuthResult?> tryAuthenticate(String accessToken) async {
    try {
      final info = await Oauth2Api(client).tokeninfo(accessToken: accessToken);

      if (info.userId == null ||
          info.email == null ||
          info.verifiedEmail != true) {
        print('Invalid OAuth2 token info.');
        return null;
      }

      if (!_config.audiences.contains(info.audience)) {
        print('Invalid audience ${info.audience} in OAuth2 token.');
        return null;
      }

      final scopes = info.scope?.split(' ') ?? [];

      return AuthResult(info.userId, info.email, scopes);
    } on ApiRequestError catch (ex) {
      print('Access denied for access token.');
      print(ex);
    } catch (ex, st) {
      print('Failed to get token info.');
      print(ex);
      print(st);
    }

    return null;
  }
}
