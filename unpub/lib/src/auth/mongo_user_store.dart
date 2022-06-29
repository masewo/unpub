import 'package:mongo_dart/mongo_dart.dart';
import 'package:unpub/src/auth/models/user.dart';
import 'package:unpub/src/auth/user_store.dart';
import 'package:unpub/src/auth/models/api_token.dart';

const userCollection = 'users';

class MongoUserStore extends UserStore {
  final Db _db;
  final DbCollection _userCollection;

  MongoUserStore(this._db) : _userCollection = _db.collection(userCollection);

  @override
  Future<void> init() async {
    await _db.createIndex(userCollection, keys: {'id': 1}, unique: true);
    await _db.createIndex(userCollection, keys: {'email': 1}, unique: true);
    await _db.createIndex(userCollection, keys: {'tokens.id': 1}, unique: true);
    await _db.createIndex(userCollection, keys: {'tokens.token': 1}, unique: true);
  }

  @override
  Future<void> add(User user) async {
    await _userCollection.insert(user.toJson());
  }

  @override
  Future<void> addToken(String userId, ApiToken token) async {
    await _userCollection.updateOne(
      where.eq('id', userId),
      modify.addToSet('tokens', token.toJson()),
    );
  }

  @override
  Future<void> deleteToken(String userId, String tokenId) async {
    await _userCollection.updateOne(
      where.eq('id', userId),
      modify.pull('tokens', {'id': tokenId})
    );
  }

  @override
  Future<User?> findById(String userId) async {
    final json = await _userCollection.findOne(where.eq('id', userId));

    if (json != null) {
      return User.fromJson(json);
    }

    return null;
  }

  @override
  Future<User?> findByEmail(String email) async {
    final json = await _userCollection.findOne(where.match('email', email, caseInsensitive: true));

    if (json != null) {
      return User.fromJson(json);
    }

    return null;
  }

  @override
  Future<User?> findByToken(String token) async {
    final json = await _userCollection.findOne(where.eq('tokens.token', token));

    if (json != null) {
      return User.fromJson(json);
    }

    return null;
  }

  @override
  Future<List<String>> getTokenScopes(String token) async {
    throw UnimplementedError();
  }
}
