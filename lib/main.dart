import 'package:flutter/material.dart';

import 'views/sign_in_view.dart';
import 'views/tab_view.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => SignInView(),
        '/home': (BuildContext context) => TabView(),
      },
    );
  }
}
