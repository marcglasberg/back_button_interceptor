// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/back_button_interceptor
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

// When pressing the back-button, a message will be printed to the console,
// and no back action will happen. In this case, the interceptor function is
// a Future.

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatefulWidget {
  @override
  DemoState createState() => DemoState();
}

class DemoState extends State<Demo> {
  //
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

  Future<bool> myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) async {
    print("BACK BUTTON!"); // Do some stuff.
    print("Waiting..."); // Do some stuff.
    await Future<dynamic>.delayed(const Duration(seconds: 2));
    print("Finished waiting."); // Do some stuff.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Back Button Interceptor Example')),
      body: Container(
        color: Colors.green,
        child: const Center(
          child: Text('Click the Back Button\n'
              'and see the message in the console.'),
        ),
      ),
    );
  }
}
