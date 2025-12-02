import 'package:flutter/material.dart';
import 'package:mi_app/presentation/screens/prelista_product_screen.dart';
import 'offline_products_screen.dart';
// import 'productos_screen.dart'; // lo dejamos comentado por ahora

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú Principal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Ver Pre-listas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrelistaProductScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.inventory),
              label: const Text('Ver Productos'),
              onPressed: () {
                // Aquí luego conectaremos la pantalla Productos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pantalla de Productos aún no implementada")),
                );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.offline_bolt),
              label: const Text('Ver Offline Productos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OfflineProductsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
