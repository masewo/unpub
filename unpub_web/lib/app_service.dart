import 'dart:convert';
import 'package:angular/angular.dart';
import 'package:http/http.dart' as http;
import 'package:unpub_web/constants.dart';
import 'src/routes.dart';
import 'package:unpub_api/models.dart';

class PackageNotExistsException implements Exception {
  final String message;
  PackageNotExistsException(this.message);
}

@Injectable()
class AppService {
  bool loading = false;
  String keyword = '';
  String token;

  String getAndClearToken() {
    var _token = token;
    token = null;
    return _token;
  }

  void clearToken() {
    token = null;
  }

  void setToken(String _token) {
    token = _token;
  }

  void setLoading(bool value) {
    loading = value;
  }

  Future _fetch(String path,
      [Map<String, dynamic> queryParameters = const {},
        String method = 'GET',
        Object body]) async {
    queryParameters.entries
        .where((entry) => entry.value == null)
        .toList()
        .forEach((entry) => queryParameters.remove(entry.key));

    var baseUrl = isProduction ? '' : 'http://localhost:4000';
    var uri = Uri.parse(baseUrl).replace(
      path: path,
      queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())),
    );

    http.Response res;
    if (method == 'GET') {
      res = await http.get(uri);
    } else if (method == 'POST') {
      res = await http.post(uri, body: json.encode(body));
    } else {
      throw 'Method $method not supported.';
    }

    var data = json.decode(res.body);

    if (data['error'] != null) {
      var error = data['error'] as String;
      if (error.contains('package not exists')) {
        throw PackageNotExistsException(error);
      }
      throw error;
    }

    return data['data'];
  }

  Future<ListApi> fetchPackages(
      {int size, int page, String sort, String q}) async {
    var res = await _fetch(
        '/webapi/packages', {'size': size, 'page': page, 'sort': sort, 'q': q});
    return ListApi.fromJson(res);
  }

  Future<WebapiDetailView> fetchPackage(String name, String version) async {
    version = version ?? 'latest';
    var res = await _fetch('/webapi/package/$name/$version');
    return WebapiDetailView.fromJson(res);
  }

  Future<Tokens> fetchTokens() async {
    var res = await _fetch('/webapi/token');
    print(res);
    return Tokens.fromJson(res);
  }

  Future<Token> createToken(Token token) async {
    var res = await _fetch('/webapi/token', {}, 'POST', token.toJson());
    return Token.fromJson(res);
  }

  getDetailUrl(package) {
    return RoutePaths.detail.toUrl(parameters: {'name': package['name']});
  }
}
