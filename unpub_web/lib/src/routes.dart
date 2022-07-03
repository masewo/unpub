import 'package:angular_router/angular_router.dart';

import 'home_component.template.dart' as home_template;
import 'list_component.template.dart' as list_template;
import 'detail_component.template.dart' as detail_template;
import 'token_component.template.dart' as token_template;
import 'new_token_component.template.dart' as new_token_template;
// import 'not_found_component.template.dart' as not_found_template;

class RoutePaths {
  static final home = RoutePath(path: '');
  static final list = RoutePath(path: 'packages');
  static final detail = RoutePath(path: 'packages/:name');
  static final detailVersion =
      RoutePath(path: 'packages/:name/versions/:version');
  static final tokens = RoutePath(path: 'tokens');
  static final newToken = RoutePath(path: 'tokens/new');
}

class Routes {
  static final home = RouteDefinition(
    routePath: RoutePaths.home,
    component: home_template.HomeComponentNgFactory,
  );
  static final list = RouteDefinition(
    routePath: RoutePaths.list,
    component: list_template.ListComponentNgFactory,
  );
  static final detail = RouteDefinition(
    routePath: RoutePaths.detail,
    component: detail_template.DetailComponentNgFactory,
  );
  static final detailVersion = RouteDefinition(
    routePath: RoutePaths.detailVersion,
    component: detail_template.DetailComponentNgFactory,
  );
  static final tokens = RouteDefinition(
    routePath: RoutePaths.tokens,
    component: token_template.TokenComponentNgFactory,
  );
  static final newToken = RouteDefinition(
    routePath: RoutePaths.newToken,
    component: new_token_template.NewTokenComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    home,
    list,
    detail,
    tokens,
    newToken,
    // RouteDefinition.redirect(
    //   path: '',
    //   redirectTo: RoutePaths.heroes.toUrl(),
    // ),
    // RouteDefinition(
    //   path: '.*',
    //   component: not_found_template.NotFoundComponentNgFactory,
    // ),
  ];
}
