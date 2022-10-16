library back_button_interceptor;

import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'merge_sort.dart';

// Developed by Marcelo Glasberg (jan 2019).

/// When you need to intercept the Android back-button, you usually add `WillPopScope` to your
/// widget tree. However, under some use cases, specially when developing stateful widgets that
/// interact with the back button, it's more convenient to use the `BackButtonInterceptor`.
///
/// For more info, see: https://pub.dartlang.org/packages/back_button_interceptor
abstract class BackButtonInterceptor implements WidgetsBinding {
  static final List<_FunctionWithZIndex> _interceptors = [];
  static final InterceptorResults results = InterceptorResults();

  static Function(Object) errorProcessing = _errorProcessing;

  static void _errorProcessing(Object error) {
    print("The BackButtonInterceptor threw an ERROR: $error.");
    Future.delayed(const Duration(), () => throw error);
  }

  static Future<void> Function() handlePopRouteFunction = WidgetsBinding.instance.handlePopRoute;

  static Future<void> Function(String?) handlePushRouteFunction =
      WidgetsBinding.instance.handlePushRoute as Future<void> Function(String?);

  /// Sets a function of type [InterceptorFunction] to be called when the back button is tapped.
  /// This function may perform some useful work, and then, if it returns `true`,
  /// the default button process (usually popping a Route) will NOT be fired.
  ///
  /// Functions added last are called first.
  ///
  /// If the optional [ifNotYetIntercepted] parameter is true, then the function will only be
  /// called if all previous functions returned `false` (that is, `stopDefaultButtonEvent` is
  /// `false`).
  ///
  /// Optionally, you may provide a [zIndex]. Functions with a valid z-index will be called before
  /// functions with a null z-index, and functions with larger z-index will be called first.
  /// When they have the same z-index, functions added last are called first.
  ///
  /// Optionally, you may provide a [name]. This is useful if you later want to removes the
  /// function by name by using the [removeByName] method.
  ///
  /// You can also provide the current [context]. That's optional, and you only need to do this if
  /// later you want to use [RouteInfo.ifRouteChanged].
  ///
  static void add(
    InterceptorFunction interceptorFunction, {
    bool ifNotYetIntercepted = false,
    int? zIndex,
    String? name,
    BuildContext? context,
  }) {
    _interceptors.insert(
        0,
        _FunctionWithZIndex(
          interceptorFunction,
          ifNotYetIntercepted,
          zIndex,
          name,
          (context == null) ? null : getCurrentNavigatorRoute(context),
        ));
    stableSort(_interceptors);
    SystemChannels.navigation.setMethodCallHandler(_handleNavigationInvocation);
  }

  /// Removes the function, by reference.
  /// Example:
  ///
  /// ```
  /// void initState() {
  ///    super.initState();
  ///    BackButtonInterceptor.add(_onBackButton);
  /// }
  ///
  /// void dispose() {
  ///    BackButtonInterceptor.remove(_onBackButton);
  ///    super.dispose();
  /// }
  ///
  /// bool _onBackButton(bool stopDefaultButtonEvent, RouteInfo info) { ... }
  /// ```
  ///
  static void remove(InterceptorFunction interceptorFunction) {
    _interceptors
        .removeWhere((interceptor) => interceptor.interceptionFunction == interceptorFunction);
  }

  /// Removes the function, by name.
  /// Example:
  ///
  /// ```
  /// void initState() {
  ///    super.initState();
  ///    BackButtonInterceptor.add(_onBackButton, name: 'myInterceptor');
  /// }
  ///
  /// void dispose() {
  ///    BackButtonInterceptor.removeByName('myInterceptor');
  ///    super.dispose();
  /// }
  ///
  /// bool _onBackButton(bool stopDefaultButtonEvent, RouteInfo info) { ... }
  /// ```
  ///
  static void removeByName(String name) {
    _interceptors.removeWhere((interceptor) => interceptor.name == name);
  }

  /// Removes all functions.
  /// Example:
  ///
  /// ```
  /// void initState() {
  ///    super.initState();
  ///    BackButtonInterceptor.add(_onBackButton);
  /// }
  ///
  /// void dispose() {
  ///    // Not recommended, because it will remove all functions,
  ///    // not only the one created above.
  ///    BackButtonInterceptor.removeAll();
  ///    super.dispose();
  /// }
  ///
  /// bool _onBackButton(bool stopDefaultButtonEvent, RouteInfo info) { ... }
  /// ```
  ///
  static void removeAll() {
    _interceptors.clear();
  }

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  static Route? getCurrentNavigatorRoute(BuildContext context) {
    Route? currentRoute;
    Navigator.popUntil(context, (route) {
      currentRoute = route;
      return true;
    });
    return currentRoute;
  }

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  static String? getCurrentNavigatorRouteName(BuildContext context) =>
      getCurrentNavigatorRoute(context)!.settings.name;

  static Future<dynamic> _handleNavigationInvocation(MethodCall methodCall) async {
    // POP.
    if (methodCall.method == 'popRoute')
      return popRoute();

    // PUSH.
    else if (methodCall.method == 'pushRoute')
      return _pushRoute(methodCall.arguments);

    // OTHER.
    else
      return Future<dynamic>.value();
  }

  /// All functions are called, in order.
  /// If any function returns true, the combined result is true,
  /// and the default button process will NOT be fired.
  ///
  /// Only if all functions return false (or null), the combined result is false,
  /// and the default button process will be fired.
  ///
  /// Each function gets a boolean that indicates the current combined result
  /// from the previous functions.
  ///
  /// Note: If the interceptor throws an error, a message will be printed to the
  /// console, and a placeholder error will not be thrown. You can change the
  /// treatment of errors by changing the static errorProcessing field.
  static Future popRoute() async {
    bool stopDefaultButtonEvent = false;

    results.clear();

    List<_FunctionWithZIndex> interceptors = List.of(_interceptors);

    for (var i = 0; i < interceptors.length; i++) {
      bool? result;

      try {
        var interceptor = interceptors[i];

        if (!interceptor.ifNotYetIntercepted || !stopDefaultButtonEvent) {
          FutureOr<bool> _result = interceptor.interceptionFunction(
            stopDefaultButtonEvent,
            RouteInfo(routeWhenAdded: interceptor.routeWhenAdded),
          );

          if (_result is bool)
            result = _result;
          // ignore: unnecessary_type_check
          else if (_result is Future<bool>)
            result = await _result;
          else
            throw AssertionError(_result.runtimeType);

          results.results.add(InterceptorResult(interceptor.name, result));
        }
      } catch (error) {
        errorProcessing(error);
      }

      if (result == true) stopDefaultButtonEvent = true;
    }

    if (stopDefaultButtonEvent)
      return Future<dynamic>.value();
    else {
      results.ifDefaultButtonEventWasFired = true;
      return handlePopRouteFunction();
    }
  }

  static Future<void> _pushRoute(dynamic arguments) =>
      handlePushRouteFunction(arguments as String?);

  /// Describes all interceptors, with their names and z-indexes.
  /// This may help you debug your interceptors, by printing them
  /// to the console, like this:
  /// `print(BackButtonInterceptor.describe());`
  static String describe() => _interceptors.join("\n");
}

typedef InterceptorFunction = FutureOr<bool> Function(
  bool stopDefaultButtonEvent,
  RouteInfo routeInfo,
);

/// Your functions can also process information about routes by using the function's RouteInfo info
/// parameter. To get the current route in the navigator, call `info.currentRoute(context)`.
/// Also, `info.routeWhenAdded` contains the route that was the current one when the interceptor
/// was added through the `BackButtonInterceptor.add()` method.
class RouteInfo {
  //

  /// The current route when the interceptor was added
  /// through the BackButtonInterceptor.add() method.
  final Route? routeWhenAdded;

  RouteInfo({this.routeWhenAdded});

  Route? currentRoute(BuildContext context) =>
      BackButtonInterceptor.getCurrentNavigatorRoute(context);

  /// Return true if the current route is NOT the same route of when the interceptor was created.
  ///
  /// This is useful if you want to create an interceptor that only runs when the current route is
  /// the same route of when the interceptor was created:
  /// ```
  /// bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
  ///    if (info.ifRouteChanged(context)) return false;
  ///    ...
  ///  }
  /// ```
  ///
  /// This method can only be called if the [context] parameter was
  /// passed to the [BackButtonInterceptor.add] method.
  ///
  bool ifRouteChanged(BuildContext context) {
    if (routeWhenAdded == null)
      throw AssertionError("The ifRouteChanged() method "
          "can only be called if the context parameter was "
          "passed to the BackButtonInterceptor.add() method.");

    return !identical(currentRoute(context), routeWhenAdded);
  }
}

class InterceptorResult {
  String? name;
  bool? stopDefaultButtonEvent;

  InterceptorResult(this.name, this.stopDefaultButtonEvent);
}

class InterceptorResults {
  int count = 0;
  List<InterceptorResult> results = [];
  bool ifDefaultButtonEventWasFired = false;

  void clear() {
    results = [];
    ifDefaultButtonEventWasFired = false;
    count++;
  }

  InterceptorResult? getNamed(String name) =>
      results.firstWhereOrNull((result) => result.name == name);
}

class _FunctionWithZIndex implements Comparable<_FunctionWithZIndex> {
  final InterceptorFunction interceptionFunction;
  final bool ifNotYetIntercepted;
  final int? zIndex;
  final String? name;
  final Route? routeWhenAdded;

  _FunctionWithZIndex(
    this.interceptionFunction,
    this.ifNotYetIntercepted,
    this.zIndex,
    this.name,
    this.routeWhenAdded,
  );

  @override
  int compareTo(_FunctionWithZIndex other) {
    if (zIndex == null && other.zIndex == null)
      return 0;
    else if (zIndex == null && other.zIndex != null)
      return 1;
    else if (zIndex != null && other.zIndex == null)
      return -1;
    else
      return other.zIndex!.compareTo(zIndex!);
  }

  @override
  String toString() =>
      'BackButtonInterceptor: $name, z-index: $zIndex (ifNotYetIntercepted: $ifNotYetIntercepted).';
}
