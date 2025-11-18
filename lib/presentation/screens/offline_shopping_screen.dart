import 'package:flutter/material.dart';
import '../../data/models/producto.dart';

class ShoppingListScreen extends StatefulWidget {
  final List<Producto> productos;

  const ShoppingListScreen({Key? key, required this.productos}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<Producto> seleccionados = [];

  double get total => seleccionados.fold(0.0, (suma, item) => suma + item.precio);

  void _toggleSeleccion(Producto producto) {
    setState(() {
      if (seleccionados.contains(producto)) {
        seleccionados.remove(producto);
      } else {
        seleccionados.add(producto);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de compra'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.productos.length,
              itemBuilder: (context, index) {
                final producto = widget.productos[index];
                final estaSeleccionado = seleccionados.contains(producto);

                return CheckboxListTile(
                  title: Text(producto.nombre),
                  subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                  value: estaSeleccionado,
                  onChanged: (_) => _toggleSeleccion(producto),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
