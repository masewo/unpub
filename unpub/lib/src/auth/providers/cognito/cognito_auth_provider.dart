import 'package:jose/jose.dart';
import 'package:unpub/src/auth/providers/auth_provider.dart';
import 'package:unpub/src/auth/models/auth_result.dart';
import 'package:unpub/src/auth/providers/cognito/cognito_auth_config.dart';
import 'package:unpub/src/auth/providers/user_info.dart';
import 'package:unpub/src/auth/user_store.dart';

class CognitoAuthProvider extends AuthProvider {
  final CognitoAuthConfig _config;

  late final String jwksUri;
  late final JsonWebKeyStore _jwkStore;

  CognitoAuthProvider(this._config, UserStore userStore, [String? proxy])
      : super(userStore, proxy);

  Future<void> init() async {
    jwksUri =
        'https://public-keys.auth.elb.${_config.region}.amazonaws.com/{key-id}';

    _jwkStore = JsonWebKeyStore();
  }

  @override
  Future<AuthResult?> tryAuthenticate(String accessToken) {
    return _authenticateJwt(accessToken);
  }

  Future<AuthResult?> _authenticateJwt(String accessToken) async {
    final jwt = JsonWebToken.unverified(accessToken);
    var keyId = jwt.claims['kid'];

    if (keyId == null || jwt.claims.subject == null ||
        jwt.claims
            .validate(
                issuer: jwt.claims.issuer,
                expiryTolerance: Duration(minutes: 1))
            .isNotEmpty) {
      print('Invalid OAuth2 token info.');
      return null;
    }

    var keySetUrl = jwksUri.replaceAll('{key-id}', keyId);
    _jwkStore.addKeySetUrl(Uri.parse(keySetUrl));

    if (!await jwt.verify(_jwkStore)) {
      print('Invalid OAuth2 token signature.');
      return null;
    }

    final scopes = jwt.claims.getTyped<String>('scope')?.split(' ') ?? [];
    final userInfo = await _getUserInfo(jwt);

    if (userInfo == null) {
      print('Invalid user info.');
      return null;
    }

    return AuthResult(userInfo.subject, userInfo.email, scopes);
  }

  UserInfo? _getUserInfo(JsonWebToken jwt) {
    final subject = jwt.claims.subject;
    final email = jwt.claims['email'] as String?;
    final emailVerified = jwt.claims['email_verified'] as bool?;

    if (subject == null || email == null || emailVerified != true) {
      return null;
    }

    return UserInfo(subject, email, emailVerified!);
  }
}
