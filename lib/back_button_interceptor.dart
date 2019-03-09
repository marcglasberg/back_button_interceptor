library back_button_interceptor;

import 'dart:async';

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
/// Functions added last are called first.
///
/// In more detail: All added functions are called, in order. If any function returns true,
/// the combined result is true, and the default button process will NOT be fired.
/// Only if all functions return false (or null), the combined result is false,
/// and the default button process will be fired.
///
/// Each function gets the boolean `stopDefaultButtonEvent` that indicates the current combined
/// result from all the previous functions. So, if some function doesn't want to fire if some other
/// previous function already fired, it can do:
///
/// ```
///    if (stopDefaultButtonEvent) return false;
/// ```
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
///
/// Note: If any of your interceptors throws an error, a message will be printed to the console,
/// but the error will not be thrown. You can change the treatment of errors by changing the
/// static errorProcessing field.
///
abstract class BackButtonInterceptor implements WidgetsBinding {
  static final List<bool Function(bool)> _interceptors = [];

  static Function(dynamic) errorProcessing =
      (error) => print("The BackButtonInterceptor threw an ERROR: $error.");

  /// Sets a function to be called when the back button is tapped.
  /// This function may perform some useful work, and then, if it returns true,
  /// the default button process (usually popping a Route) will not be fired.
  /// Functions added last are called first.
  static void add(bool Function(bool) onBackButton) {
    _interceptors.insert(0, onBackButton);
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
  /// If any function returns true, the combined result is true,
  /// and the default button process will NOT be fired.
  ///
  /// Only if all functions return false (or null), the combined result is false,
  /// and the default button process will be fired.
  ///
  /// Each function gets a boolean that indicates the current combined result
  /// from the previous functions.
  ///
  /// Note: If the interceptor throws an error, a message will be printed to the console,
  /// but the error will not be thrown. You can change the treatment of errors by changing the
  /// static errorProcessing field.
  static Future _popRoute() {
    bool stopDefaultButtonEvent = false;

    for (var i = 0; i < _interceptors.length; i++) {
      bool result;

      try {
        result = _interceptors[i](stopDefaultButtonEvent);
      } catch (error) {
        errorProcessing(error);
      }

      if (result == true) stopDefaultButtonEvent = true;
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
