import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:unpub/src/auth/mongo_user_store.dart';
import 'package:unpub/src/auth/providers/auth_provider.dart';
import 'package:unpub/src/auth/providers/google/google_auth_config.dart';
import 'package:unpub/src/auth/providers/oidc/oidc_auth_config.dart';
import 'package:unpub/src/auth/providers/oidc/oidc_auth_provider.dart';
import 'package:unpub/src/auth/providers/google/google_auth_provider.dart';
import 'package:unpub/src/auth/providers/token/token_auth_provider.dart';
import 'package:unpub/src/utils.dart';
import 'package:unpub/unpub.dart' as unpub;

main(List<String> args) async {
  var parser = ArgParser();
  parser.addOption('host', abbr: 'h', defaultsTo: '0.0.0.0');
  parser.addOption('port', abbr: 'p', defaultsTo: '4000');
  parser.addOption('database',
      abbr: 'd', defaultsTo: 'mongodb://localhost:27017/dart_pub');
  parser.addOption('config', abbr: 'c', defaultsTo: '../config/config-default.yaml');
  parser.addOption('auth-provider',
      abbr: 'a', defaultsTo: 'google', allowed: ['google', 'oidc']);
  parser.addFlag('strict-auth', defaultsTo: false);

  var results = parser.parse(args);

  var host = results['host'] as String?;
  var port = int.parse(results['port'] as String);
  var dbUri = results['database'] as String;

  if (results.rest.isNotEmpty) {
    print('Got unexpected arguments: "${results.rest.join(' ')}".\n\nUsage:\n');
    print(parser.usage);
    exit(1);
  }

  final configPath = results.wasParsed('config')
      ? Uri.parse(results['config'])
      : Platform.script.resolve(results['config']);

  final configYaml = await File.fromUri(configPath).readAsString();
  final config = loadYamlAsMap(configYaml);

  if (config == null) {
    print("Config at '$configPath' doesn't exist.");
    exit(1);
  }

  final getValue = <T>(String name) {
    if (results.wasParsed(name)) {
      return results[name] as T;
    }
    return config.containsKey(name) ? config[name] as T : results[name] as T;
  };

  final getConfigValue = <T>(String name) {
    if (!config.containsKey(name)) {
      print("Missing key '$name' in config.");
      exit(1);
    }
    return config[name] as T;
  };

  final strictAuth = getValue<bool>('strict-auth');
  final selectedAuthProvider = getValue<String>('auth-provider');
  final authProviderConfig = getConfigValue<Map<String, dynamic>>('auth-provider-config');

  final db = Db(dbUri);
  await db.open();

  var baseDir = path.absolute('unpub-packages');

  AuthProvider? authProvider;

  switch (selectedAuthProvider) {
    case 'google':
      final config = GoogleAuthConfig.fromConfig(authProviderConfig['google']);
      authProvider = GoogleAuthProvider(config);
      break;
    case 'oidc':
      final config = OidcAuthConfig.fromConfig(authProviderConfig['oidc']);
      authProvider = OidcAuthProvider(config);
      await (authProvider as OidcAuthProvider).init();
      break;
    default:
      print('Invalid auth provider $selectedAuthProvider');
      exit(1);
  }

  final userStore = MongoUserStore(db);
  await userStore.init();

  final tokenAuthProvider = TokenAuthProvider(userStore);

  var app = unpub.App(
    metaStore: unpub.MongoStore(db),
    packageStore: unpub.FileStore(baseDir),
    authProvider: authProvider,
    tokenAuthProvider: tokenAuthProvider,
  );

  var server = await app.serve(host, port, strictAuth);
  print('Serving at http://${server.address.host}:${server.port}');
}
