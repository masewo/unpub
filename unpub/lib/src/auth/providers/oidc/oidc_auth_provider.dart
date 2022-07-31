import 'dart:convert';
import 'dart:io';

import 'package:jose/jose.dart';
import 'package:unpub/src/auth/providers/auth_provider.dart';
import 'package:unpub/src/auth/models/auth_result.dart';
import 'package:unpub/src/auth/providers/oidc/oidc_auth_config.dart';
import 'package:unpub/src/auth/providers/user_info.dart';
import 'package:unpub/src/auth/user_store.dart';

class OidcAuthProvider extends AuthProvider {
  final OidcAuthConfig _config;

  late final Uri _userInfoEndpoint;
  late final Uri _introspectionEndpoint;
  late final JsonWebKeyStore _jwkStore;

  OidcAuthProvider(this._config, UserStore userStore, [String? proxy]) : super(userStore, proxy);

  Future<void> init() async {
    final issuer = _config.issuerUri;
    final discoveryUrl = issuer.path.endsWith('/')
        ? issuer.replace(path: '${issuer.path}.well-known/openid-configuration')
        : issuer.replace(
            path: '${issuer.path}/.well-known/openid-configuration');

    final discoveryDocument = await client.read(discoveryUrl);
    final discoveryData = jsonDecode(discoveryDocument) as Map<String, dynamic>;

    _userInfoEndpoint = Uri.parse(discoveryData['userinfo_endpoint'] as String);
    _introspectionEndpoint =
        Uri.parse(discoveryData['introspection_endpoint'] as String);
    _jwkStore = JsonWebKeyStore()
      ..addKeySetUrl(Uri.parse(discoveryData['jwks_uri'] as String));
  }

  @override
  Future<AuthResult?> tryAuthenticate(String accessToken) {
    if (_config.jwt != null) {
      return _authenticateJwt(accessToken);
    } else {
      return _authenticateOpaque(accessToken);
    }
  }

  Future<AuthResult?> _authenticateJwt(String accessToken) async {
    final jwt = JsonWebToken.unverified(accessToken);

    if (jwt.claims.subject == null ||
        jwt.claims
            .validate(
                issuer: _config.issuerUri,
                expiryTolerance: Duration(minutes: 1))
            .isNotEmpty) {
      print('Invalid OAuth2 token info.');
      return null;
    }

    if (jwt.claims.audience?.any((a) => _config.jwt!.audiences.contains(a)) !=
        true) {
      print('Invalid OAuth2 token audience.');
      return null;
    }

    if (!await jwt.verify(_jwkStore)) {
      print('Invalid OAuth2 token signature.');
      return null;
    }

    final scopes = jwt.claims.getTyped<String>('scope')?.split(' ') ?? [];
    final userInfo = await _getUserInfo(accessToken);

    if (userInfo == null) {
      print('Invalid user info.');
      return null;
    }

    return AuthResult(userInfo.subject, userInfo.email, scopes);
  }

  Future<AuthResult?> _authenticateOpaque(String accessToken) async {
    final clientId = _config.opaque!.introspectionClientId;
    final clientSecret = _config.opaque!.introspectionClientSecret;

    final basicAuth = base64.encode(utf8.encode('$clientId:$clientSecret'));

    final response = await client.post(_introspectionEndpoint,
        body: {'token': accessToken},
        headers: {HttpHeaders.authorizationHeader: 'Basic $basicAuth'});

    if (response.statusCode != HttpStatus.ok) {
      print('Failed to introspect OAuth2 token.');
      return null;
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;

    if (result['active'] as bool != true) {
      print('Inactive OAuth2 token.');
      return null;
    }

    final scopes = (result['scope'] as String?)?.split(' ') ?? [];
    final userInfo = await _getUserInfo(accessToken);

    if (userInfo == null) {
      print('Invalid user info.');
      return null;
    }

    return AuthResult(userInfo.subject, userInfo.email, scopes);
  }

  Future<UserInfo?> _getUserInfo(String accessToken) async {
    final userInfoResponse = await client.read(_userInfoEndpoint,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'});

    final userInfo = jsonDecode(userInfoResponse) as Map<String, dynamic>;

    final subject = userInfo['sub'] as String?;
    final email = userInfo['email'] as String?;
    final emailVerified = userInfo['email_verified'] as bool?;

    if (subject == null || email == null || emailVerified != true) {
      return null;
    }

    return UserInfo(subject, email, emailVerified!);
  }
}
