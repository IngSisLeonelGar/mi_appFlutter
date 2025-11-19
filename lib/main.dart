import 'package:flutter/material.dart';
import 'package:mi_app/presentation/screens/offline_add_products_screen.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/offline_products_screen.dart';
import 'domain/controllers/product_controller.dart';
import 'data/repositories/product_repository.dart'; // este archivo debe existir aunque sea básico
import 'data/services/local_storage_service.dart';


void main() {
  final storage = LocalStorageService();
  final repo = ProductRepository(storage); // ⚠ pasar storage

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController(repo)),
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
        '/offline_add_products': (context) => const AddProductScreen(),
      },
    );
  }
}
