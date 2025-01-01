## 8.0.1

* Sponsored by [MyText.ai](https://mytext.ai)

[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)

## 7.1.0

* Added static methods `BackButtonInterceptor.getInnermostNamedNavigatorRoute`
  and `BackButtonInterceptor.getInnermostNamedNavigatorRouteName`. Those methods will
  get the current navigator route, if that route has a name. If it doesn't have a name,
  it will go back until it finds a route with a name. This can be helpful if you are in
  a dialog or bottom sheet, and you want to know the route of the screen it's in.

## 7.0.3

* Updated the README to include: "To make it work on Android 13 and up, set this to
  `false` in the Android manifest: `android:enableOnBackInvokedCallback="false"`

## 7.0.1

* When your interceptor throws an error, you now also get its stacktrace. This is a
  breaking change only if you define your own `errorProcessing` function. If that's the
  case and your code breaks, simply change the signature of your error processing function
  from `static Function(Object)` to `static Function(Object, StackTrace)`.

## 6.0.1

* Flutter 3.0

## 5.1.0

* Don't use this version.

## 5.0.2

* Docs improvement. This is the version you should use with Flutter <3.0.

## 5.0.1

* Now the interceptor function can return `bool` or `Future<bool>`:  
  `typedef InterceptorFunction = FutureOr<bool> Function(bool stopDefaultButtonEvent, RouteInfo routeInfo);`

## 5.0.0

* Nullsafety.

## 4.4.1

* Method ifRouteChanged() now works with named and unnamed routes.

## 4.3.0

* Breaking change: The interceptor functions now get a second parameter `RouteInfo info`.
  To upgrade from version [4.2.4] you just need to add this parameter to your functions
  (you have to add it, but you don't need to use it, unless you need the new
  functionalities it provides).

* Please read the "Notes" section of the README for more information
  about the new `RouteInfo` parameter.

## 3.0.0

* Prevents silent errors swallowing.

## 2.0.0

* Multiple interceptors.

## 1.0.0

* Tested thoroughly. Single interceptor.
