import 'package:flutter/material.dart';
import 'package:flutter_itsolutions_task/ui/widgets/home_screen/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'IT Solutions Task',
      home: HomePage(),
    );
  }
}
