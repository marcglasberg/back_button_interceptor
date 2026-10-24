import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _RouteObserver with WidgetsBindingObserver {
  final List<RouteInformation> received = [];

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    received.add(routeInformation);
    return true;
  }
}

/// Sends [call] on the navigation channel the way the platform does, and returns the reply.
Future<Object?> _sendNavigationMessage(WidgetTester tester, MethodCall call) async {
  Object? reply;
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(call),
    (data) => reply = data == null ? null : SystemChannels.navigation.codec.decodeEnvelope(data),
  );
  return reply;
}

void main() {
  late _RouteObserver observer;

  setUp(() {
    observer = _RouteObserver();
    // A no-op interceptor: `add` installs this package's navigation-channel handler.
    BackButtonInterceptor.add(_interceptor);
  });

  tearDown(() => BackButtonInterceptor.remove(_interceptor));

  testWidgets('a pushRouteInformation message still reaches the app once add was called',
      (tester) async {
    // A deep link reaching a running app, and on the web the browser's Back and Forward buttons.
    tester.binding.addObserver(observer);
    addTearDown(() => tester.binding.removeObserver(observer));

    final reply = await _sendNavigationMessage(
      tester,
      const MethodCall(
        'pushRouteInformation',
        <String, Object?>{'location': '/orders/42', 'state': null},
      ),
    );

    expect(observer.received.map((info) => info.uri.toString()), ['/orders/42']);
    // The platform reads the reply: on iOS (Flutter 3.24 to 3.47) anything but `true` hands a
    // universal link back to Safari. Before 3.24 `handlePushRoute` returns void and the reply is
    // null.
    expect(reply, isTrue);
  });

  testWidgets('a legacy pushRoute message still reaches the app once add was called',
      (tester) async {
    tester.binding.addObserver(observer);
    addTearDown(() => tester.binding.removeObserver(observer));

    await _sendNavigationMessage(tester, const MethodCall('pushRoute', '/orders/42'));

    expect(observer.received.map((info) => info.uri.toString()), ['/orders/42']);
  });

  testWidgets('handlePushRouteInformationFunction can be overridden', (tester) async {
    final defaultFunction = BackButtonInterceptor.handlePushRouteInformationFunction;
    addTearDown(() => BackButtonInterceptor.handlePushRouteInformationFunction = defaultFunction);
    final received = <Map<Object?, Object?>>[];
    BackButtonInterceptor.handlePushRouteInformationFunction = (arguments) async {
      received.add(arguments);
    };

    await _sendNavigationMessage(
      tester,
      const MethodCall(
        'pushRouteInformation',
        <String, Object?>{'location': '/orders/42', 'state': 'restored'},
      ),
    );

    expect(received, [
      {'location': '/orders/42', 'state': 'restored'},
    ]);
  });
}

bool _interceptor(bool stopDefaultButtonEvent, RouteInfo info) => false;
