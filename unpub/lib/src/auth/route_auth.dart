import 'package:meta/meta_meta.dart';

enum _Auth {
  always,
  configurable,
  anonymous,
}

@Target({TargetKind.method})
class Auth {
  // used for reflection
  // ignore: unused_field
  final _Auth _auth;

  const Auth._internal(this._auth);

  static const Auth always = Auth._internal(_Auth.always);
  static const Auth configurable = Auth._internal(_Auth.configurable);
  static const Auth anonymous = Auth._internal(_Auth.anonymous);
}

class RouteAuth {
  String method;
  Pattern _path;
  _Auth _auth;

  static final _placeholder = RegExp(r'<[\w_]+>');

  RouteAuth._(this.method, String path, this._auth)
      : _path = RegExp('^${path.replaceAll(_placeholder, r'[^/]+')}\$',
            caseSensitive: false);

  factory RouteAuth.always(String method, String path) =>
      RouteAuth._(method, path, _Auth.always);
  factory RouteAuth.configurable(String method, String path) =>
      RouteAuth._(method, path, _Auth.configurable);
  factory RouteAuth.anonymous(String method, String path) =>
      RouteAuth._(method, path, _Auth.anonymous);

  bool get isAlways => _auth == _Auth.always;
  bool get isConfigurable => _auth == _Auth.configurable;
  bool get isAnonymous => _auth == _Auth.anonymous;

  bool match(String requestMethod, String requestPath) =>
      method == requestMethod && _path.matchAsPrefix(requestPath) != null;
}
