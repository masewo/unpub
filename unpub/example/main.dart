import 'package:mongo_dart/mongo_dart.dart';
import 'package:unpub/src/auth/mongo_user_store.dart';
import 'package:unpub/src/auth/providers/oidc/oidc_auth_config.dart';
import 'package:unpub/src/auth/providers/oidc/oidc_auth_provider.dart';
import 'package:unpub/src/auth/providers/token/token_auth_provider.dart';
import 'package:unpub/unpub.dart' as unpub;

main(List<String> args) async {
  final db = Db('mongodb://localhost:27017/dart_pub');
  await db.open(); // make sure the MongoDB connection opened

  //final authConfig = GoogleAuthConfig([Constants.unpubAuthAudience]);
  final authConfig = OidcAuthConfig.jwt(
      issuerUri: Uri.parse('http://localhost:9090/realms/master'),
      audiences: ['account']);

  final userStore = MongoUserStore(db);
  await userStore.init();

  final authProvider = OidcAuthProvider(authConfig, userStore);
  await authProvider.init();
  final tokenAuthProvider = TokenAuthProvider(userStore);

  final app = unpub.App(
    metaStore: unpub.MongoStore(db),
    packageStore: unpub.FileStore('./unpub-packages'),
    authProvider: authProvider,
    tokenAuthProvider: tokenAuthProvider,
  );

  final server = await app.serve('0.0.0.0', 4000, true);
  print('Serving at http://${server.address.host}:${server.port}');
}
