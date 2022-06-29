import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:unpub/src/auth/mongo_user_store.dart';
import 'package:unpub/src/auth/providers/mock_auth_provider.dart';
import 'package:unpub/src/auth/providers/mock_token_auth_provider.dart';
import 'package:unpub/unpub.dart' as unpub;
import 'package:mongo_dart/mongo_dart.dart';

final notExistingPacakge = 'not_existing_package';
final baseDir = path.absolute('unpub-packages');
final pubHostedUrl = 'http://localhost:4000';
final baseUri = Uri.parse(pubHostedUrl);

final package0 = 'package_0';
final package1 = 'package_1';
final email0 = 'email0@example.com';
final email1 = 'email1@example.com';
final email2 = 'email2@example.com';
final email3 = 'email3@example.com';
final scope = 'unpub:user';

String token(String userId, String email) =>
    base64.encode(utf8.encode(jsonEncode({'user_id': userId, 'email': email, 'scope': scope})));

createServer() async {
  final db = Db('mongodb://localhost:27017/dart_pub_test');
  await db.open();

  var mongoStore = unpub.MongoStore(db);
  var mongoUserStore = MongoUserStore(db);
  await mongoUserStore.init();

  var app = unpub.App(
    metaStore: mongoStore,
    packageStore: unpub.FileStore(baseDir),
    authProvider: MockAuthProvider(mongoUserStore),
    tokenAuthProvider: MockTokenAuthProvider(mongoUserStore),
  );

  var server = await app.serve('0.0.0.0', 4000);
  return server;
}

Future<http.Response> getVersions(String package) {
  package = Uri.encodeComponent(package);
  return http.get(baseUri.resolve('/api/packages/$package'));
}

Future<http.Response> getSpecificVersion(String package, String version) {
  package = Uri.encodeComponent(package);
  version = Uri.encodeComponent(version);
  return http.get(baseUri.resolve('/api/packages/$package/versions/$version'));
}

Future<ProcessResult> pubPublish(String name, String version) {
  return Process.run('dart', ['pub', 'publish', '--force'],
      workingDirectory: path.absolute('test/fixtures', name, version),
      environment: {'PUB_HOSTED_URL': pubHostedUrl});
}

Future<ProcessResult> pubUploader(String name, String operation, String email) {
  assert(['add', 'remove'].contains(operation), 'operation error');

  return Process.run('dart', ['pub', 'uploader', operation, email],
      workingDirectory: path.absolute('test/fixtures', name, '0.0.1'),
      environment: {'PUB_HOSTED_URL': pubHostedUrl});
}

Future<ProcessResult> pubAddToken(String token) async {
  await pubRemoveToken();

  final process = await Process.start('dart',
      ['pub', 'token', 'add', pubHostedUrl.replaceAll('http', 'https')]);

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  process.stdout.transform(utf8.decoder).forEach(stdoutBuffer.write);
  process.stderr.transform(utf8.decoder).forEach(stderrBuffer.write);

  process.stdin.write(token);

  await process.stdin.flush();
  await process.stdin.close();

  final code = await process.exitCode;

  final appdata = Platform.environment['APPDATA'] ?? r'C:\Users\husar\AppData\Roaming';
  final tokensFile = File(appdata + r'\dart\pub-tokens.json');
  var tokensContent = await tokensFile.readAsString();
  tokensContent = tokensContent.replaceFirst(pubHostedUrl.replaceAll('http', 'https'), pubHostedUrl);
  await tokensFile.writeAsString(tokensContent);

  return ProcessResult(process.pid, code, stdoutBuffer, stderrBuffer);
}

Future<ProcessResult> pubRemoveToken() {
  return Process.run('dart', ['pub', 'token', 'remove', pubHostedUrl]);
}
