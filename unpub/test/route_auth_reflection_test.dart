import 'package:collection/src/iterable_extensions.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';
import 'package:unpub/src/auth/route_auth.dart';
import 'package:unpub/src/auth/route_auth_finder.dart';

main() {
  group('correct', () {
    final routeOptions = findRouteAuthsFromDeclarations(App);

    test('matched routes length', () {
      expect(routeOptions.length, equals(7));
    });

    test('get anonymous', () {
      final routeOption = routeOptions.singleWhereOrNull((r) => r.match('GET', '/get/anonymous'));
      expect(routeOption, isNotNull);
      expect(routeOption!.isAnonymous, isTrue);
    });

    test('post configurable', () {
      final routeOption = routeOptions.singleWhereOrNull((r) => r.match('POST', '/post/configurable'));
      expect(routeOption, isNotNull);
      expect(routeOption!.isConfigurable, isTrue);
    });

    test('delete always', () {
      final routeOption = routeOptions.singleWhereOrNull((r) => r.match('DELETE', '/delete/always'));
      expect(routeOption, isNotNull);
      expect(routeOption!.isAlways, isTrue);
    });

    test('multiple routes always', () {
      final routeOption1 = routeOptions.singleWhereOrNull((r) => r.match('GET', '/get/multiple-routes/always/1'));
      expect(routeOption1, isNotNull);
      expect(routeOption1!.isAlways, isTrue);
      
      final routeOption2 = routeOptions.singleWhereOrNull((r) => r.match('GET', '/get/multiple-routes/always/2'));
      expect(routeOption2, isNotNull);
      expect(routeOption2!.isAlways, isTrue);
      
      final routeOption3 = routeOptions.singleWhereOrNull((r) => r.match('GET', '/get/multiple-routes/always/3'));
      expect(routeOption3, isNotNull);
      expect(routeOption3!.isAlways, isTrue);
    });

    test('get with parameter always', () {
      final routeOption = routeOptions.singleWhereOrNull((r) => r.match('GET', '/get/xxx/always'));
      expect(routeOption, isNotNull);
      expect(routeOption!.isAlways, isTrue);
    });

    test('get ignore - no auth', () {
      final routeOption = routeOptions.singleWhereOrNull((r) => r.match('GET', '/get/ignore/no-auth'));
      expect(routeOption, isNull);
    });
  });

  group('incorrect', () {
    test('multiple auths', () {
      expect(() => findRouteAuthsFromDeclarations(AppMultipleAuths), throwsStateError);
    });

    test('no route', () {
      expect(() => findRouteAuthsFromDeclarations(AppNoRoute), throwsStateError);
    });
  });
}

class App {
  @Auth.anonymous
  @Route.get('/get/anonymous')
  Future<void> getAnonymous() async {}

  @Auth.configurable
  @Route.post('/post/configurable')
  Future<void> postConfigurable() async {}

  @Auth.always
  @Route.delete('/delete/always')
  Future<void> deleteAlways() async {}

  @Auth.always
  @Route.get('/get/multiple-routes/always/1')
  @Route.get('/get/multiple-routes/always/2')
  @Route.get('/get/multiple-routes/always/3')
  Future<void> getMultipleRoutesAlways() async {}

  @Auth.always
  @Route.get('/get/<param>/always')
  Future<void> getWithParameterAlways() async {}

  @Route.get('/get/ignore/no-auth')
  Future<void> getIgnoreNoAuth() async {}
}

class AppMultipleAuths {
  @Auth.always
  @Auth.configurable
  @Route.get('/get/error/multiple-auths')
  Future<void> getAnonymous() async {}
}

class AppNoRoute {
  @Auth.always
  Future<void> getAnonymous() async {}
}
