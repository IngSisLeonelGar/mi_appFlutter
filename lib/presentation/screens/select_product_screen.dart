import 'package:flutter/material.dart';
import '../../data/models/producto.dart';

class SelectedProductsScreen extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> cantidades;

  const SelectedProductsScreen({super.key, required this.productos, required this.cantidades});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos Seleccionados')),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (_, index) {
          final p = productos[index];
          final cantidad = cantidades[p.id] ?? 1;

          return ListTile(
            title: Text(p.nombre),
            subtitle: Text('Cantidad: $cantidad'),
            trailing: Text('\$${(p.precio * cantidad).toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
