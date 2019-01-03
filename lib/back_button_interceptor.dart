library back_button_interceptor;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Developed by Marcelo Glasberg (jan 2019).
///
/// When you need to intercept the Android back-button, you usually add [WillPopScope]
/// to your widget tree. However, under some use cases, specially when developing stateful
/// widgets that interact with the back button, it may be more convenient to use the
/// [BackButtonInterceptor].
///
/// You may add functions to be called when the back button is tapped.
/// These functions may perform some useful work, and then, if any of them return true,
/// the default button process (usually popping a Route) will not be fired.
///
/// In more detail: All added functions are called, in order. If any function returns true,
/// the combinedResult is true, and the default button process will NOT be fired.
/// Only if all functions return false (or null), the combinedResult is false,
/// and the default button process will be fired. Each function gets a boolean that
/// indicates the current combinedResult from all the previous functions.
///
/// Note: After you've finished you MUST remove each function by calling the remove() method.
///
/// Example usage:
///
/// ```
///  @override
///  void initState() {
///    super.initState();
///    BackButtonInterceptor.add(myInterceptor);
///  }
///
///  @override
///  void dispose() {
///    BackButtonInterceptor.remove(myInterceptor);
///    super.dispose();
///  }
///
///  bool myInterceptor(bool stopDefaultButtonEvent) {
///    print("BACK BUTTON!");
///    return true;
///  }
///
/// ```
abstract class BackButtonInterceptor implements WidgetsBinding {
  static List<bool Function(bool)> _interceptors = [];

  /// Sets a function to be called when the back button is tapped.
  /// This function may perform some useful work, and then, if it returns true,
  /// the default button process (usually popping a Route) will not be fired.
  static void add(bool Function(bool) onBackButton) {
    _interceptors.add(onBackButton);
    SystemChannels.navigation.setMethodCallHandler(_handleNavigationInvocation);
  }

  /// Removes the function.
  static void remove(bool Function(bool) onBackButton) {
    _interceptors.remove(onBackButton);
  }

  /// Removes all functions.
  static void removeAll() {
    _interceptors.clear();
  }

  static Future<dynamic> _handleNavigationInvocation(MethodCall methodCall) async {
    // POP.
    if (methodCall.method == 'popRoute')
      return _popRoute();

    // PUSH.
    else if (methodCall.method == 'pushRoute')
      return _pushRoute(methodCall.arguments);

    // OTHER.
    else
      return Future<dynamic>.value();
  }

  /// All functions are called, in order.
  /// If any function returns true, the combinedResult is true,
  /// and the default button process will NOT be fired.
  ///
  /// Only if all functions return false (or null), the combinedResult is false,
  /// and the default button process will be fired.
  ///
  /// Each function gets a boolean that indicates the current combinedResult
  /// from the previous functions.
  static Future _popRoute() {
    bool stopDefaultButtonEvent = false;

    for (var i = 0; i < _interceptors.length; i++) {
      if (_interceptors[i](stopDefaultButtonEvent) == true) stopDefaultButtonEvent = true;
    }

    if (stopDefaultButtonEvent)
      return Future<dynamic>.value();
    else
      return WidgetsBinding.instance.handlePopRoute();
  }

  static Future<void> _pushRoute(dynamic arguments) {
    return WidgetsBinding.instance.handlePushRoute(arguments);
  }
}
