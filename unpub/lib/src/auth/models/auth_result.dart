class AuthResult {
  final String? userId;
  final String? email;
  final List<String> scopes;

  AuthResult(this.userId, this.email, this.scopes);
}
