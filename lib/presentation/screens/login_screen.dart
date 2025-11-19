import 'package:flutter/material.dart';
import 'package:mi_app/data/repositories/product_repository.dart';
import 'package:provider/provider.dart';
import '../../domain/controllers/product_controller.dart';
import '../../data/services/local_storage_service.dart';
import 'offline_products_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final repo = ProductRepository(LocalStorageService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica de login online
                print('Login online...');
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                // Ir a pantalla de productos offline
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      // Aquí creamos el ProductController con LocalStorageService
                      return ChangeNotifierProvider(
                        create: (_) => ProductController(repo),
                        child: const OfflineProductsScreen(),
                      );
                    },
                  ),
                );
              },
              child: const Text('Ver productos sin internet'),
            ),
          ],
        ),
      ),
    );
  }
}
