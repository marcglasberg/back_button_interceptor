## [7.0.1] - 2023/08/10

* When your interceptor throws an error, you now also get its stacktrace. This is a breaking change
  only if you define your own `errorProcessing` function. If that's the case and your code breaks,
  simply change the signature of your error processing function
  from `static Function(Object)` to `static Function(Object, StackTrace)`.

## [6.0.2] - 2020/09/20

* Docs improvement.

## [6.0.1] - 2020/05/13

* Flutter 3.0

## [6.0.0] - 2020/05/13

* Don't use this version with Flutter <3.0.

## [5.1.0] - 2020/05/12

* Don't use this version.

## [5.0.2] - 2020/09/20

* Docs improvement. This is the version you should use with Flutter <3.0.

## [5.0.1] - 2021/06/17

* Now the interceptor function can return `bool` or `Future<bool>`:  
  `typedef InterceptorFunction = FutureOr<bool> Function(bool stopDefaultButtonEvent, RouteInfo routeInfo);`

## [5.0.0] - 2021/03/05

* Nullsafety.

## [4.4.2] - 2020/02/15

* Small improvements.

## [4.4.2] - 2020/02/15

* Small improvements.

## [4.4.1] - 2020/10/22

* Method ifRouteChanged() now works with named and unnamed routes.

## [4.3.1] - 2020/09/14

* Docs improvement.

## [4.3.0] - 2020/06/22

* Breaking change: The interceptor functions now get a second
  parameter `RouteInfo info`. To upgrade from version [4.2.4]
  you just need to add this parameter to your functions (you
  have to add it, but you don't need to use it, unless you
  need the new functionalities it provides).

* Please read the "Notes" section of the README for more information
  about the new `RouteInfo` parameter.

## [4.2.4] - 2020/05/19

* Docs improvement.

## [4.2.3] - 2019/12/18

* BackButtonInterceptor.describe() to help debug complex interceptors.

## [4.2.2] - 2019/10/28

* Stack removal.

## [4.1.1] - 2019/08/13

* Docs improvement.

## [4.0.6] - 2019/04/23

* More testing features.

## [4.0.5] - 2019/04/22

* Small fix.

## [4.0.4] - 2019/04/17

* Testing features.

## [4.0.2] - 2019/04/02

* Helper methods to get the current route name, and the current route stack.

## [4.0.1] - 2019/03/09

* Functions added last are fired first. Parameters ifNotYetIntercepted and zIndex.

## [3.0.0] - 2019/03/03

* Prevents silent errors swallowing.

## [2.0.2] - 2019/02/22

* Fixed dart version.

## [2.0.0] - 2019/01/02

* Multiple interceptors.

## [1.0.0] - 2019/01/02

* Tested thoroughly. Single interceptor.





