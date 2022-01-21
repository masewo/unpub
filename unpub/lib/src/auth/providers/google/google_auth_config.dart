class GoogleAuthConfig {
  final List<String> audiences;

  GoogleAuthConfig(this.audiences);

  factory GoogleAuthConfig.fromConfig(Map<String, dynamic> config) {
    final audiences = (config['audiences'] as List<dynamic>).cast<String>();

    return GoogleAuthConfig(audiences);
  }
}
