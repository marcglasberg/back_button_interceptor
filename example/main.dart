import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatefulWidget {
  @override
  DemoState createState() => new DemoState();
}

class DemoState extends State<Demo> {
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

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Back Button Interceptor Example')),
      body: Container(color: Colors.green),
    );
  }
}
