import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/controllers/product_controller.dart';
import '../widgets/product_tile.dart';
import 'offline_add_products_screen.dart';
import 'select_product_screen.dart';

class OfflineProductsScreen extends StatefulWidget {
  const OfflineProductsScreen({super.key});

  @override
  State<OfflineProductsScreen> createState() => _OfflineProductsScreenState();
}

class _OfflineProductsScreenState extends State<OfflineProductsScreen> {
  final _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().cargarProductos();
    });
  }  

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
    

    controller.limpiarBuscador = () {
      _searchController.clear();
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => controller.exportarProductos(),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => controller.importarProductos(),
          ),
        ],

        // 🔍 Buscador
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => controller.filtrarProductos(value),
            ),
          ),
        ),
      ),

      // 🔥 ENVOLVEMOS TODO EL BODY AQUÍ PARA CERRAR EL TECLADO
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),

        child: controller.cargando
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.only(
                  bottom: controller.seleccionados.isEmpty ? 16 : 100, // 100 = altura del bottomSheet + margen
                ),
                itemCount: controller.productos.length,
                itemBuilder: (_, index) {
                  final p = controller.productos[index];
                  return ProductTile(
                    producto: p,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddProductScreen(producto: p),
                        ),
                      ).then((_) => controller.cargarProductos());
                    },
                  );
                },
              )

      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addProduct',
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              ).then((_) => controller.cargarProductos());
            },
          ),
          const SizedBox(height: 12),
          if (controller.seleccionados.isNotEmpty)
            FloatingActionButton(
              heroTag: 'selectedProducts',
              backgroundColor: Colors.green,
              child: const Icon(Icons.list),
              onPressed: () {
                final productosSeleccionados = controller.productos
                    .where((p) => controller.seleccionados.contains(p.id))
                    .toList();
                final cantidadesStringKey = controller.cantidades.map(
                  (key, value) => MapEntry(key.toString(), value),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectedProductsScreen(
                      productos: productosSeleccionados,
                      cantidades: cantidadesStringKey,
                    ),
                  ),
                );
              },
            ),
        ],
      ),



      bottomSheet: controller.seleccionados.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${controller.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: controller.limpiarSeleccion,
                    child: const Text('Limpiar selección'),
                  ),
                ],
              ),
            ),
    );
  }
}
