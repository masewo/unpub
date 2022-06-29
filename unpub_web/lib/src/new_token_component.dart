import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:unpub_api/models.dart';
import 'package:unpub_web/app_service.dart';
import 'package:unpub_web/src/routes.dart';

const List<String> _expirations = [
  '7 days',
  '30 days',
  '60 days',
  '90 days',
  '1 year',
];

@Component(
  selector: 'my-app',
  templateUrl: 'new_token_component.html',
  directives: [routerDirectives, coreDirectives, formDirectives],
  exports: [RoutePaths],
  pipes: [DatePipe],
)
class NewTokenComponent {
  final Router _router;
  final AppService appService;

  NewTokenComponent(this._router, this.appService);

  Token model = Token('', _expirations[1], 'read', null);
  bool submitted = false;

  List<String> get expirations => _expirations;

  List<String> get scopes => ['read', 'write'];
  List<String> get requiredScopes => ['read'];

  void onSubmit() {
    _createToken();
  }

  void _createToken() async {
    Token token = await appService.createToken(model);

    appService.setToken(token.value);
    _gotoTokens();
  }

  void _gotoTokens() {
    _router.navigate('tokens');
  }

  void onChange(String scope, bool isChecked) {
    var scopes = model.scope.split(' ');

    if (isChecked) {
      if (!scopes.contains(scope)) {
        scopes.add(scope);
      }
    } else {
      scopes.remove(scope);
    }

    model.scope = scopes.join(' ');
    print(model.scope);
  }

  /// Returns a map of CSS class names representing the state of [control].
  Map<String, bool> setCssValidityClass(NgControl control) {
    final validityClass = control.valid == true ? 'is-valid' : 'is-invalid';
    return {validityClass: true};
  }

  void clear() {
    model.note = '';
    model.expiration = _expirations[1];
    model.scope = 'read';
  }
}
