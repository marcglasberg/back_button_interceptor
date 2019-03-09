# back_button_interceptor

When you need to intercept the Android back-button, you usually add `WillPopScope` 
to your widget tree. However, under some use cases, specially when developing stateful 
widgets that interact with the back button, it may be more convenient to use the 
`BackButtonInterceptor`.

You may add functions to be called when the back button is tapped.
These functions may perform some useful work, and then, if any of them return true,
the default button process (usually popping a Route) will not be fired.
Functions added last are called first.

In more detail: All added functions are called, in order. If any function returns true,
the combined result is true, and the default button process will NOT be fired.
Only if all functions return false (or null), the combined result is false,
and the default button process will be fired. 

Each function gets the boolean `stopDefaultButtonEvent` that indicates the current combined result 
from all the previous functions. So, if some function doesn't want to fire if some other previous 
function already fired, it can do:
  
    if (stopDefaultButtonEvent) return false;

**Note:** After you've finished you MUST remove each function by calling the `remove()` method.


**Note:** If any of your interceptors throws an error, a message will be printed to the console,
but the error will not be thrown. You can change the treatment of errors by changing the
static `errorProcessing` field.

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

Don't forget to check the [example tab](https://pub.dartlang.org/packages/back_button_interceptor#-example-tab-).
 
See also:

  * https://docs.flutter.io/flutter/widgets/WillPopScope-class.html
  * https://stackoverflow.com/questions/45916658/de-activate-system-back-button-in-flutter-app-toddler-navigation
