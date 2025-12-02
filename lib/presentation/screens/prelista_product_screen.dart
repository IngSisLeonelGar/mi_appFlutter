import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/controllers/prelista_controller.dart';
import '../../data/models/prelista.dart';
import '../../domain/controllers/product_controller.dart';
import 'select_product_screen.dart';
import '../../data/models/producto.dart';

class PrelistaProductScreen extends StatelessWidget {
  const PrelistaProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preListaController = context.watch<PreListaController>();
    final productController = context.read<ProductController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Pre-listas")),
      body: preListaController.preListas.isEmpty
          ? const Center(child: Text("No hay pre-listas guardadas"))
          : ListView.builder(
              itemCount: preListaController.preListas.length,
              itemBuilder: (_, index) {
                final pre = preListaController.preListas[index];

                return ListTile(
                  title: Text(pre.nombre),
                  subtitle: Text(
                      "${pre.productos.length} productos • Total: \$${_calcularTotal(pre, productController.productos).toStringAsFixed(2)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      preListaController.eliminarPreLista(pre.id);
                    },
                  ),
                  onTap: () {
                    // Obtener lista de productos de la pre-lista
                    final productosSeleccionados = productController.productos
                        .where((p) => pre.productos.containsKey(p.id))
                        .toList();

                    final cantidadesSeleccionadas = Map<int, int>.from(pre.productos);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectedProductsScreen(
                          productos: productosSeleccionados,
                          cantidades: cantidadesSeleccionadas,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Función para calcular total de la pre-lista
  double _calcularTotal(PreLista pre, List<Producto> todosProductos) {
    double total = 0;
    for (var entry in pre.productos.entries) {
      final prod = todosProductos.firstWhere(
          (p) => p.id == entry.key,
          orElse: () => Producto(id: entry.key, nombre: "Desconocido", precio: 0));
      total += prod.precio * entry.value;
    }
    return total;
  }
}
