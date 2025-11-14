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
  List<Producto> productosSeleccionados = [];
  Map<int, int> cantidades = {}; // key = id del producto, value = cantidad

  TextEditingController searchController = TextEditingController();
  bool cargando = true;
  double get total => productosSeleccionados.fold(
    0.0,
    (suma, item) {
      int cantidad = cantidades[item.id] ?? 1;
      return suma + (item.precio * cantidad);
    },
  );

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

  void _toggleSeleccion(Producto producto) {
    setState(() {
      if (productosSeleccionados.contains(producto)) {
        productosSeleccionados.remove(producto);
        cantidades.remove(producto.id); // eliminar cantidad también
      } else {
        productosSeleccionados.add(producto);
        cantidades[producto.id] = 1; // cantidad inicial = 1
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
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: productosFiltrados.length,
              itemBuilder: (context, index) {
                final producto = productosFiltrados[index];
                final seleccionado = productosSeleccionados.contains(producto);
                return Column(
                  children: [
                    ListTile(
                      leading: Checkbox(
                        value: seleccionado,
                        onChanged: (_) => _toggleSeleccion(producto),
                      ),
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
                                await _storageService.eliminarProducto(producto.id);
                                cargarProductos();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                      // 🔥 MOSTRAR CONTROLES DE CANTIDAD SOLO SI ESTÁ SELECCIONADO
                    if (seleccionado)
                      Padding(
                        padding: const EdgeInsets.only(left: 60, right: 16, bottom: 8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  int actual = cantidades[producto.id] ?? 1;
                                  if (actual > 1) cantidades[producto.id] = actual - 1;
                                });
                              },
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                            ),
                            Text(
                              "${cantidades[producto.id] ?? 1}",
                              style: const TextStyle(fontSize: 18),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  int actual = cantidades[producto.id] ?? 1;
                                  cantidades[producto.id] = actual + 1;
                                });
                              },
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 1),
                  ],
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // <-- Lo sube 80px encima del total
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
            cargarProductos();
          },
          child: const Icon(Icons.add),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
       bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black87,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TOTAL:",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
             // 🔥 Si hay productos seleccionados, mostrar botón limpiar
            if (productosSeleccionados.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    productosSeleccionados.clear();
                  });
                },
                child: const Text(
                  "Limpiar",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            Text(
              "\$${total.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
    
  }
  
}
