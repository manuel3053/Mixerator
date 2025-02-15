import 'package:flutter/material.dart';
import 'package:mixerator/ui/views/homepage_viewmodel.dart';
import 'package:mixerator/ui/widgets/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          //useMaterial3: true,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black,
                  brightness: Brightness.dark
          ),
          brightness: Brightness.dark
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: const TextTheme(labelLarge: TextStyle(fontSize: 40))),
      home: Homepage(viewmodel: HomepageViewmodel()),
    );
  }

}

