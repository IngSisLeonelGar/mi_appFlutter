import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/producto.dart';
import '../../domain/controllers/prelista_controller.dart';
import '../../data/models/prelista.dart';

class SelectedProductsScreen extends StatefulWidget {
  final List<Producto> productos;
  final Map<int, int> cantidades;

  const SelectedProductsScreen({
    super.key,
    required this.productos,
    required this.cantidades,
  });

  @override
  State<SelectedProductsScreen> createState() => _SelectedProductsScreenState();
}

class _SelectedProductsScreenState extends State<SelectedProductsScreen> {

  // Función para editar la cantidad
  void _editarCantidad(BuildContext context, int productoId, int cantidadActual) async {
    final controller = TextEditingController(text: cantidadActual.toString());

    final nuevaCantidadStr = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar cantidad"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Ingrese nueva cantidad",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancelar
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text), // Confirmar
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );

    if (nuevaCantidadStr == null) return; // Canceló

    final nuevaCantidad = int.tryParse(nuevaCantidadStr);
    if (nuevaCantidad != null && nuevaCantidad > 0) {
      setState(() {
        widget.cantidades[productoId] = nuevaCantidad;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcular total dinámico
    final total = widget.productos.fold<double>(
      0,
      (sum, p) => sum + p.precio * (widget.cantidades[p.id] ?? 1),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Productos Seleccionados')),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.productos.length,
              itemBuilder: (_, index) {
                final p = widget.productos[index];
                final cantidad = widget.cantidades[p.id] ?? 1;

                return ListTile(
                  title: Text(p.nombre),
                  subtitle: Text('Cantidad: $cantidad'),
                  trailing: Text('\$${(p.precio * cantidad).toStringAsFixed(2)}'),
                  onTap: () => _editarCantidad(context, p.id, cantidad),
                );
              },
            ),
          ),

          // Total al final
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),

      // Botón Guardar pre-lista con padding para no tapar el total
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: FloatingActionButton.extended(
          icon: const Icon(Icons.save),
          label: const Text("Guardar pre-lista"),
          onPressed: () => _guardarPreLista(context),
        ),
      ),
    );
  }

  /// Guardar pre lista
  void _guardarPreLista(BuildContext context) async {
    final nombreController = TextEditingController();

    final nombre = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nombre de la pre-lista"),
          content: TextField(
            controller: nombreController,
            decoration: const InputDecoration(
              hintText: "Ej: Cliente Juan",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Guardar"),
              onPressed: () {
                if (nombreController.text.trim().isEmpty) return;
                Navigator.pop(context, nombreController.text.trim());
              },
            ),
          ],
        );
      },
    );

    if (nombre == null) return; // cancelado

    final Map<int, int> cantidadesInt = Map<int, int>.from(widget.cantidades);

    final pre = PreLista(
      id: DateTime.now().millisecondsSinceEpoch,
      nombre: nombre,
      productos: cantidadesInt,
    );

    context.read<PreListaController>().agregarPreLista(pre);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pre-lista '$nombre' guardada")),
    );
  }
}
