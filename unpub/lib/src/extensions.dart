import 'package:shelf/shelf.dart';
import 'package:unpub/src/auth/models/auth_result.dart';

extension RequestExtensions on Request {
  AuthResult get authResult => context['unpub.auth.auth_result'] as AuthResult;
}
