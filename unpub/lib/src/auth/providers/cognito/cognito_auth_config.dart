class CognitoAuthConfig {
  final String region;

  CognitoAuthConfig._internal(this.region);

  factory CognitoAuthConfig.fromConfig(Map<String, dynamic> config) {
    final region = config['region'] as String;

    return CognitoAuthConfig._internal(region);
  }

  factory CognitoAuthConfig.region(
      {required String region}) {
    return CognitoAuthConfig._internal(region);
  }
}
