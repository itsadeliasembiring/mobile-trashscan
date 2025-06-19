import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_trashscan/Providers/points.provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes.dart';
import 'Menu/menu.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ikyeohhgyjpjcjmaljzj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlreWVvaGhneWpwamNqbWFsanpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2OTE2OTIsImV4cCI6MjA2NDI2NzY5Mn0.s8hiCPcy91qNJRmtp9YPrBV2FNf-iGH3JxRqduKcXOY',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: appRoutes,
      //  home: Menu(),
    );
  }
}