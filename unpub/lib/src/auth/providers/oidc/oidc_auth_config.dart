class OidcAuthConfig {
  final Uri issuerUri;
  final _Jwt? jwt;
  final _OpaqueToken? opaque;

  OidcAuthConfig._internal(this.issuerUri, this.jwt, this.opaque);

  factory OidcAuthConfig.fromConfig(Map<String, dynamic> config) {
    final issuerUri = Uri.parse(config['issuer-uri'] as String);

    _Jwt? jwt;
    _OpaqueToken? opaque;

    if (config.containsKey('jwt') && config.containsKey('opaque')) {
      throw StateError("Either 'jwt' or 'opaque' must be configured for OIDC.");
    }

    if (config.containsKey('jwt')) {
      final jwtConfig = config['jwt'] as Map<String, dynamic>;
      final audiences =
          (jwtConfig['audiences'] as List<dynamic>).cast<String>();
      jwt = _Jwt(audiences);
    } else if (config.containsKey('opaque')) {
      final opaqueConfig = config['opaque'] as Map<String, dynamic>;
      final introspectionClientId = opaqueConfig['introspection-client-id'];
      final introspectionClientSecret =
          opaqueConfig['introspection-client-secret'];
      opaque = _OpaqueToken(introspectionClientId, introspectionClientSecret);
    } else {
      throw StateError("Either 'jwt' or 'opaque' must be configured for OIDC.");
    }

    return OidcAuthConfig._internal(issuerUri, jwt, opaque);
  }

  factory OidcAuthConfig.jwt(
      {required Uri issuerUri, required List<String> audiences}) {
    return OidcAuthConfig._internal(issuerUri, _Jwt(audiences), null);
  }

  factory OidcAuthConfig.opaque(
      {required Uri issuerUri,
      required String introspectionClientId,
      required String introspectionClientSecret}) {
    return OidcAuthConfig._internal(issuerUri, null,
        _OpaqueToken(introspectionClientId, introspectionClientSecret));
  }
}

class _Jwt {
  final List<String> audiences;

  _Jwt(this.audiences);
}

class _OpaqueToken {
  final String introspectionClientId;
  final String introspectionClientSecret;

  _OpaqueToken(this.introspectionClientId, this.introspectionClientSecret);
}
