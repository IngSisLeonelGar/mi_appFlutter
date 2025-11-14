import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/offline_products_screen.dart';
// más imports de pantallas futuras aquí

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi appTienda',
      debugShowCheckedModeBanner: false, // quita el banner de debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Pantalla inicial
      initialRoute: '/login',
      builder: (context, child) {
        return SafeArea(
          child: child!,
        );
      },

      // Rutas nombradas
      routes: {
        '/login': (context) => const LoginScreen(),
        '/offline_products': (context) => const OfflineProductsScreen(),
        // '/home': (context) => const HomeScreen(), // ejemplo futuro
        // '/product_details': (context) => const ProductDetailsScreen(),
      },
    );
  }
}
