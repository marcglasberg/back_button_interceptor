# back_button_interceptor

The `BackButtonInterceptor` may be used to intercept the Android back-button,
as an alternative to `WillPopScope`.

You may set a function to be called when the back button is tapped.
This function may perform some useful work, and then, if it returns false,
the default button process (usually popping a Route) will not be fired.

**Note:** Only one function may be defined at a time, and setting a function will
remove the previous one. After you've finished you MUST remove the function
by setting it to `null`, or calling the `remove()` method.

## Usage

### Import the package

First, add back_button_interceptor [as a dependency](https://pub.dartlang.org/packages/back_button_interceptor#-installing-tab-) in your pubspec.yaml

Then, import it:

    import 'package:back_button_interceptor/back_button_interceptor.dart';

### Example usage

    @override
    void initState() {
        super.initState();
        BackButtonInterceptor.set(() {
           print("BACK BUTTON!");
           return false;
           });
    }
    
     @override
     void dispose() {
        BackButtonInterceptor.remove();
        super.dispose();
     }

Don't forget to check the [example tab](https://pub.dartlang.org/packages/back_button_interceptor#-example-tab-).
 
See also:

  * https://docs.flutter.io/flutter/widgets/WillPopScope-class.html
  * https://stackoverflow.com/questions/45916658/de-activate-system-back-button-in-flutter-app-toddler-navigation
