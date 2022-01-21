import 'package:unpub/src/auth/models/api_token.dart';
import 'package:unpub/src/auth/models/user.dart';

abstract class UserStore {
  Future<void> init();
  Future<void> add(User user);
  Future<void> addToken(String userId, ApiToken token);
  Future<void> deleteToken(String userId, String token);
  Future<User?> findById(String userId);
  Future<User?> findByEmail(String email);
  Future<User?> findByToken(String token);
  Future<List<String>> getTokenScopes(String token);
}
