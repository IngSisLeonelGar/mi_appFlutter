import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/offline_products_screen.dart';
import 'domain/controllers/product_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi appTienda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/offline_products': (context) => const OfflineProductsScreen(),
      },
    );
  }
}
