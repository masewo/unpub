import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:unpub_api/models.dart';
import 'package:unpub_web/app_service.dart';
import 'package:unpub_web/src/routes.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'token_component.html',
  directives: [routerDirectives, coreDirectives],
  exports: [RoutePaths],
  pipes: [DatePipe],
)
class TokenComponent implements OnActivate, OnDeactivate {
  final AppService appService;

  TokenComponent(this.appService);

  String token;
  WebApiTokens data;

  @override
  void onActivate(RouterState previous, RouterState current) {
    token = appService.getAndClearToken();
    _fetchTokens();
  }

  void _fetchTokens() async {
    var tokenList = await appService.fetchTokens();
    data = tokenList;
  }

  @override
  void onDeactivate(RouterState current, RouterState next) {
    appService.clearToken();
  }
}