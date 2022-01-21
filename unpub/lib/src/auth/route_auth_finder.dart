import 'dart:mirrors';

import 'package:shelf_router/shelf_router.dart';
import 'package:unpub/src/auth/route_auth.dart';

List<RouteAuth> findRouteAuthsFromDeclarations(Type type) {
  final appClass = reflectClass(type);
  final routeMetadata = appClass.declarations.values
      .map((d) => d.metadata)
      .where((m) => m.any((i) => i.reflectee is Auth))
      .toList();

  final routeAuthList = <RouteAuth>[];

  for (final metadata in routeMetadata) {
    final auth = metadata.singleWhere((e) => e.reflectee is Auth);
    final routes = metadata.where((e) => e.reflectee is Route);

    if (routes.isEmpty) {
      throw StateError(
          '`Auth` can only be used with `Route` annotated methods.');
    }

    final authSymbol =
        MirrorSystem.getSymbol('_auth', auth.type.owner as LibraryMirror);
    final authType = auth.getField(authSymbol).reflectee;

    for (final route in routes.map((r) => r.reflectee as Route)) {
      final routeAuthClass = reflectClass(RouteAuth);
      final constructorSymbol =
          MirrorSystem.getSymbol('_', routeAuthClass.owner as LibraryMirror);
      final instance = routeAuthClass
          .newInstance(constructorSymbol, [route.verb, route.route, authType]);
      routeAuthList.add(instance.reflectee);
    }
  }

  return routeAuthList;
}
