import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:unpub/src/auth/models/auth_result.dart';
import 'package:unpub/src/auth/user_store.dart';

abstract class AuthProvider {
  /// http(s) proxy to call user info endpoints
  final String? proxy;
  final UserStore userStore;

  Client? _client;

  AuthProvider(this.userStore, [this.proxy]);

  Client get client => _client ??= proxy == null
      ? Client()
      : IOClient(HttpClient()
        ..findProxy = (url) => HttpClient.findProxyFromEnvironment(url,
            environment: {"https_proxy": proxy!}));

  Future<AuthResult?> tryAuthenticate(String token);

  void close() {
    _client?.close();
  }
}
