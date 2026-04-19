import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://nxccznovewlvgzovwlad.supabase.co',
    anonKey: 'sb_publishable_rSg84p5uQodKQDMkNs5EJw_6OyafSqJ',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'proyecto_rpv',
      home: Scaffold(
        appBar: AppBar(title: const Text('Mi Aplicación Flutter')),
      ),
    );
  }
}
