import 'package:flutter/material.dart';
import 'package:mi_app/screens/offline_add_products_screen.dart';
import '../models/producto.dart';
import '../services/local_storage_service.dart';


class OfflineProductsScreen extends StatefulWidget {
  const OfflineProductsScreen({Key? key}) : super(key: key);

  @override
  State<OfflineProductsScreen> createState() => _OfflineProductsScreenState();
}

class _OfflineProductsScreenState extends State<OfflineProductsScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];
  TextEditingController searchController = TextEditingController();
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
  final lista = await _storageService.cargarProductos();
  setState(() {
    productos = lista;
    if (searchController.text.isEmpty) {
        productosFiltrados = List.from(lista);
      } else {
        productosFiltrados = lista.where((p) =>
            p.nombre.toLowerCase().contains(searchController.text.toLowerCase())
        ).toList();
      }
    cargando = false;
  });
}
void _filtrarProductos(String query) {
  setState(() {
    if (query.isEmpty) {
      productosFiltrados = List.from(productos);
    } else {
      productosFiltrados = productos.where((producto) {
        return producto.nombre.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar producto...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _filtrarProductos, // Llama al filtrado cada vez que escribes
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              await _storageService.exportarProductos();
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await _storageService.importarProductos();
              cargarProductos(); // recargar lista después de importar
            },
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : productosFiltrados.isEmpty
           ? const Center(child: Text('No hay productos'))
          : ListView.builder(
              itemCount: productosFiltrados.length,
              itemBuilder: (context, index) {
                  final producto = productosFiltrados[index];
                  return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductScreen(producto: producto),
                            ),
                          );
                          cargarProductos();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar borrado'),
                              content: Text('¿Seguro que quieres borrar "${producto.nombre}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Borrar'),
                                ),
                              ],
                            ),
                          );

                          if (confirmar ?? false) {
                            // Borrar producto del storage
                            await _storageService.eliminarProducto(producto.id);
                            cargarProductos();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Abrir pantalla para agregar producto
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          // Recargar la lista cuando regresamos
          cargarProductos();
        },
        child: const Icon(Icons.add),
    ),
    );
    
  }
  
}
