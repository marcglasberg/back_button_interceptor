[![pub package](https://img.shields.io/pub/v/back_button_interceptor.svg)](https://pub.dartlang.org/packages/back_button_interceptor)

# back_button_interceptor

In simple cases, when you need to intercept the Android back-button, you usually add `WillPopScope` 
to your widget tree. However, when developing stateful widgets that interact with the back button, 
it's more convenient to use the `BackButtonInterceptor`.

You may add **interceptor functions** to be called when the back button is tapped.
These functions may perform some useful work, and then, if any of them return true,
the default button process (usually popping a Route) will not be fired.

In more detail: All added functions are called, in order. If any function returns true,
the combined result is true, and the default button process will NOT be fired.
Only if all functions return false (or null), the combined result is false,
and the default button process will be fired. 

Optionally, you may provide a **z-index**. Functions with a valid z-index will be called before 
functions with a null z-index, and functions with larger z-index will be called first. 
When they have the same z-index, functions added last are called first.

Each function gets the boolean `stopDefaultButtonEvent` that indicates the current combined 
result from all the previous functions. So, if some function doesn't want to fire if some 
other previous function already fired, it can do:
  
    if (stopDefaultButtonEvent) return false;

The same result may be obtained if the optional `ifNotYetIntercepted` parameter is true. 
Then the function will only be called if all previous functions returned false 
(that is, if `stopDefaultButtonEvent` is false).

### Notes
* After you've finished you MUST remove each function by calling the `remove()` method.
Alternatively, you may also provide a `name` when adding a function, and then later remove it
by calling the `removeByName(name)` method.

* If any of your interceptors throw an error, the error message will be printed to the console,
but the error thrown will be a general error with not much information. 
You can change the treatment of errors by changing the static `errorProcessing` field.

* Your functions can also process information about routes 
by using the function's `RouteInfo info` parameter. 
To get the current route in the navigator, call `info.currentRoute(context)`.
Also, `info.routeWhenAdded` contains the route that was the current one 
when the interceptor was added through the `BackButtonInterceptor.add()` method. 

* You can set up some function so that it only runs when the current route is 
the same route of when the interceptor was created. To that end, you can use
`info.ifRouteChanged()` method: 
                         
   ```dart
   bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {    
     if (info.ifRouteChanged(context)) return false;
     ...
   }    
   ```               
  
  This means the interceptor function is temporarily disabled while, 
  for example, a dialog is open.             

* You can set up some function so that it only runs in certain routes:
                        
   ```dart
   bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {    
     if (["myRoute1", "myRoute2", "myRoute3"]
        .contains(info.currentRoute(context))) return false;
     ...
   }    
   ```               
  

* Both `info.routeWhenAdded` and `info.ifRouteChanged()` only work 
if you passed the `context` parameter to the `BackButtonInterceptor.add()` method. 
Otherwise, `info.routeWhenAdded` will be `null` and `info.ifRouteChanged()` 
will thrown an error.

* The current route can also be obtained by using the
static method `BackButtonInterceptor.getCurrentNavigatorRouteName(context)`.

## Import the package

Add back_button_interceptor [as a dependency](https://pub.dartlang.org/packages/back_button_interceptor#-installing-tab-) 
in your pubspec.yaml. Then, import it:

    import 'package:back_button_interceptor/back_button_interceptor.dart';

## Examples

### Intercepting

    @override
    void initState() {
       super.initState();
       BackButtonInterceptor.add(myInterceptor);
    }
    
    @override
    void dispose() {
       BackButtonInterceptor.remove(myInterceptor);
       super.dispose();
    }
    
    bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
       print("BACK BUTTON!"); // Do some stuff.
       return true;
    }


### Named function and z-index

    @override
    void initState() {
       super.initState();
       BackButtonInterceptor.add(myInterceptor, zIndex:2, name:"SomeName");
    }
    
    @override
    void dispose() {
       BackButtonInterceptor.removeByName("SomeName");
       super.dispose();
    }
    
    bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
       print("BACK BUTTON!"); // Do some stuff.
       return true;
    }

### Runnable Examples

1. <a href="https://github.com/marcglasberg/back_button_interceptor/blob/master/example/lib/main.dart">main</a>

   Intercepts the back-button and prints a string to the console.

2. <a href="https://github.com/marcglasberg/back_button_interceptor/blob/master/example/lib/main_complex_example.dart">main_complex_example</a>

   The first screen has a button which opens a second screen. 
   The second screen has 3 red squares. 
   By tapping the Android back-button (or the "pop" button) each square turns blue, one by one. 
   Only when all squares are blue, tapping the back-button once more will return to the previous screen.
   Also, if you click the "Open Dialog" button, the interceptors are disabled while the dialog is open.

3. <a href="https://github.com/marcglasberg/back_button_interceptor/blob/master/example/test/main_complex_example_test.dart">main_complex_example_test</a>
   
   This package is test friendly, and this examples shows how to test the back button.

 
## Testing

For testing purposes, the `BackButtonInterceptor.popRoute()` method may be called directly, 
to simulate pressing the back button. The list of all fired functions and their results is  
recorded in the `BackButtonInterceptor.results` static variable.  

_Note:_ You may want to add `BackButtonInterceptor.removeAll();` 
to your test's `setUp` function,
so that you remove old interceptors between tests.

## Debugging

In complex cases, to make it easier for you to debug your interceptors, 
you may print them to the console, with their names and z-indexes, by doing:

```dart
print(BackButtonInterceptor.describe());
```
  

## See also:

  * https://docs.flutter.io/flutter/widgets/WillPopScope-class.html
  * https://stackoverflow.com/questions/45916658/de-activate-system-back-button-in-flutter-app-toddler-navigation
  
***

*The Flutter packages I've authored:* 
* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18n_extension">i18n_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a> 
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a> 
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>
* <a href="https://pub.dev/packages/assorted_layout_widgets">assorted_layout_widgets</a>
* <a href="https://pub.dev/packages/weak_map">weak_map</a>

*My Medium Articles:*
* <a href="https://medium.com/flutter-community/https-medium-com-marcglasberg-async-redux-33ac5e27d5f6">Async Redux: Flutter’s non-boilerplate version of Redux</a> (versions: <a href="https://medium.com/flutterando/async-redux-pt-brasil-e783ceb13c43">Português</a>)
* <a href="https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9">i18n_extension</a> (versions: <a href="https://medium.com/flutterando/qual-a-forma-f%C3%A1cil-de-traduzir-seu-app-flutter-para-outros-idiomas-ab5178cf0336">Português</a>)
* <a href="https://medium.com/flutter-community/flutter-the-advanced-layout-rule-even-beginners-must-know-edc9516d1a2">Flutter: The Advanced Layout Rule Even Beginners Must Know</a> (versions: <a href="https://habr.com/ru/post/500210/">русский</a>)

*My article in the official Flutter documentation*:
* <a href="https://flutter.dev/docs/development/ui/layout/constraints">Understanding constraints</a>

<br>_Marcelo Glasberg:_<br>
_https://github.com/marcglasberg_<br>
_https://twitter.com/glasbergmarcelo_<br>
_https://stackoverflow.com/users/3411681/marcg_<br>
_https://medium.com/@marcglasberg_<br>
