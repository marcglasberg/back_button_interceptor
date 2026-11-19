import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _PushObserver with WidgetsBindingObserver {
  String? route;

  @override
  Future<bool> didPushRoute(String route) async {
    this.route = route;
    return true;
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final originalPop = BackButtonInterceptor.handlePopRouteFunction;
  final originalPush = BackButtonInterceptor.handlePushRouteFunction;
  var defaultPops = 0;

  setUp(() {
    defaultPops = 0;
    BackButtonInterceptor.removeAll();
    BackButtonInterceptor.handlePopRouteFunction = () async {
      defaultPops++;
    };
  });
  tearDown(() {
    BackButtonInterceptor.removeAll();
    BackButtonInterceptor.handlePopRouteFunction = originalPop;
    BackButtonInterceptor.handlePushRouteFunction = originalPush;
    SystemChannels.navigation.setMethodCallHandler(null);
  });

  test('interceptors run by priority, share the result and can skip intercepted events',
      () async {
    final calls = <String>[];
    BackButtonInterceptor.add((isStopped, info) {
      calls.add('low:$isStopped');
      return false;
    }, zIndex: 1);
    BackButtonInterceptor.add((isStopped, info) {
      calls.add('first:$isStopped');
      return true;
    }, zIndex: 2);
    BackButtonInterceptor.add((isStopped, info) async {
      calls.add('last:$isStopped');
      return false;
    }, zIndex: 2);
    BackButtonInterceptor.add((isStopped, info) {
      calls.add('skipped');
      return false;
    }, ifNotYetIntercepted: true);
    await BackButtonInterceptor.popRoute();
    expect(calls, ['last:false', 'first:false', 'low:true']);
    expect(defaultPops, 0);
  });

  test('removal by callback and by name restores the default pop behavior', () async {
    bool intercept(bool isStopped, RouteInfo info) => true;
    BackButtonInterceptor.add(intercept);
    BackButtonInterceptor.add((isStopped, info) => true, name: 'named');
    BackButtonInterceptor.remove(intercept);
    BackButtonInterceptor.removeByName('named');
    await BackButtonInterceptor.popRoute();
    expect(defaultPops, 1);
  });

  test('the default push adapter uses the binding without an invalid nullable cast',
      () async {
    final observer = _PushObserver();
    binding.addObserver(observer);
    addTearDown(() => binding.removeObserver(observer));
    await originalPush('/framework');
    expect(observer.route, '/framework');
    await originalPush(null);
    expect(observer.route, '/framework');
  });

  test('pushRoute is forwarded to the binding with the original route', () async {
    String? route;
    BackButtonInterceptor.handlePushRouteFunction = (value) async {
      route = value;
    };
    BackButtonInterceptor.add((isStopped, info) => false);
    final completer = <void>[];
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      const JSONMethodCodec().encodeMethodCall(const MethodCall('pushRoute', '/details')),
      (_) {
        completer.add(null);
      },
    );
    await Future<void>.delayed(Duration.zero);
    expect(route, '/details');
    expect(completer, hasLength(1));
  });
}
