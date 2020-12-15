import 'package:experiment/ui/home_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeUI(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        primaryColorDark: Colors.cyan,
        splashColor: Colors.cyan,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
