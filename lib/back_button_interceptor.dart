library back_button_interceptor;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Developed by Marcelo Glasberg (jan 2019).
///
/// The `BackButtonInterceptor` may be used to intercept the Android back-button,
/// as an alternative to `WillPopScope`.
///
/// You may set a function to be called when the back button is tapped.
/// This function may perform some useful work, and then, if it returns false,
/// the default button process (usually popping a Route) will not be fired.
///
/// Note: Only one function may be defined at a time, and setting a function will
/// remove the previous one. After you've finished you MUST remove the function
/// by setting it to null, or calling the remove() method.
///
/// Example usage:
///
/// ```
/// @override
/// void initState() {
///     super.initState();
///     BackButtonInterceptor.set(() {
///        print("BACK BUTTON!");
///        return false;
///        });
/// }
///
///  @override
///  void dispose() {
///     BackButtonInterceptor.remove();
///     super.dispose();
///  }
///
/// ```
abstract class BackButtonInterceptor implements WidgetsBinding {
  static bool Function() _onBackButton;

  /// Sets a function to be called when the back button is tapped.
  /// This function may perform some useful work, and then, if it returns false,
  /// the default button process (usually popping a Route) will not be fired.
  static void set(bool Function() onBackButton) {
    _onBackButton = onBackButton;
    SystemChannels.navigation.setMethodCallHandler(_handleNavigationInvocation);
  }

  /// Removes the function.
  static void remove() {
    _onBackButton = null;
  }

  static Future<dynamic> _handleNavigationInvocation(MethodCall methodCall) async {
    if (methodCall.method == 'popRoute') {
      if (_onBackButton != null && _onBackButton() == false)
        return Future<dynamic>.value();
      else
        return WidgetsBinding.instance.handlePopRoute();
    } else if (methodCall.method == 'pushRoute') {
      return WidgetsBinding.instance.handlePushRoute(methodCall.arguments);
    } else
      return Future<dynamic>.value();
  }
}
