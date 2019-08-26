# back_button_interceptor

In simple cases, when you need to intercept the Android back-button, you usually add `WillPopScope` 
to your widget tree. However, when developing stateful widgets that interact with the back button, 
it's more convenient to use the `BackButtonInterceptor`.

You may add functions to be called when the back button is tapped.
These functions may perform some useful work, and then, if any of them return true,
the default button process (usually popping a Route) will not be fired.

In more detail: All added functions are called, in order. If any function returns true,
the combined result is true, and the default button process will NOT be fired.
Only if all functions return false (or null), the combined result is false,
and the default button process will be fired. 

Optionally, you may provide a z-index. Functions with a valid z-index will be called before 
functions with a null z-index, and functions with larger z-index will be called first. 
When they have the same z-index, functions added last are called first.

Each function gets the boolean `stopDefaultButtonEvent` that indicates the current combined 
result from all the previous functions. So, if some function doesn't want to fire if some 
other previous function already fired, it can do:
  
    if (stopDefaultButtonEvent) return false;

The same result may be obtained if the optional `ifNotYetIntercepted` parameter is true. 
Then the function will only be called if all previous functions returned false 
(that is, if `stopDefaultButtonEvent` is false).

**Note:** After you've finished you MUST remove each function by calling the `remove()` method.
Alternatively, you may also provide a `name` when adding a function, and then later remove it
by calling the `removeByName(name)` method.

**Note:** If any of your interceptors throws an error, a message will be printed to the console,
but the error will not be thrown. You can change the treatment of errors by changing the
static `errorProcessing` field.

**Note:** If your functions need to know the current route in the navigator, you may use the helper
static method `BackButtonInterceptor.getCurrentNavigatorRouteName(context)`.
To get all routes, you may use `getCurrentNavigatorRouteStack(context)`.

## Usage

### Import the package

First, add back_button_interceptor [as a dependency](https://pub.dartlang.org/packages/back_button_interceptor#-installing-tab-) in your pubspec.yaml

Then, import it:

    import 'package:back_button_interceptor/back_button_interceptor.dart';

### Example usage

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
    
    bool myInterceptor(bool stopDefaultButtonEvent) {
       print("BACK BUTTON!"); // Do some stuff.
       return true;
    }


### Example with named function and z-index

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
    
    bool myInterceptor(bool stopDefaultButtonEvent) {
       print("BACK BUTTON!"); // Do some stuff.
       return true;
    }

## Runnable Examples

Don't forget to check the [example tab](https://pub.dartlang.org/packages/back_button_interceptor#-example-tab-).
`main.dart` just intercepts the back-button and prints a string to the console.

`back_button_interceptor/example/complex_example/main.dart` in the GitHub repository is more involved. 
The first screen has a button which opens a second screen. 
The second screen has 3 red squares. But tapping the Android back-button (or the "pop" button) 
each square turns blue, one by one. Only when all squares are blue, tapping the back-button once 
more will return to the previous screen. 

This package is test friendly. See an example on testing the back-button here: 
`back_button_interceptor/test/complex_example/main_test.dart`.
 
## Testing

For testing purposes, the `BackButtonInterceptor.popRoute()` method may be called directly, 
to simulate pressing the back button. The list of all fired functions and their results is  
recorded in the `BackButtonInterceptor.results` static variable.  

## See also:

  * https://docs.flutter.io/flutter/widgets/WillPopScope-class.html
  * https://stackoverflow.com/questions/45916658/de-activate-system-back-button-in-flutter-app-toddler-navigation
  
***

*The Flutter packages I've authored:* 
* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a> 
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a> 
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>

---<br>_https://github.com/marcglasberg_<br>
_https://twitter.com/glasbergmarcelo_<br>
_https://stackoverflow.com/users/3411681/marcg_<br>
_https://medium.com/@marcglasberg_<br>
