import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/producto.dart';
import '../../domain/controllers/product_controller.dart';

class ProductTile extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;

  const ProductTile({
    super.key,
    required this.producto,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
    final cantidadController = controller.getCantidadController(producto.id);
    final focusNode = controller.getCantidadFocusNode(producto.id);
    final seleccionado = controller.seleccionados.contains(producto.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.toggleSeleccion(producto.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seleccionado ? Colors.blue : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  // NOMBRE + PRECIO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(producto.nombre,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${producto.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 15),
                        ),
                      ],
                    ),
                  ),

                  // BOTONES EDITAR / BORRAR
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirmar'),
                          content: const Text(
                              '¿Estás seguro que quieres eliminar este producto?'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await controller.eliminarProducto(producto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Producto eliminado')),
                        );
                      }
                    },
                  ),
                ],
              ),

              // ➤ CANTIDAD SOLO SI ESTÁ SELECCIONADO
              if (seleccionado)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 8),
                  child: SizedBox(
                    width: 80,
                    child: TextField(
                      controller: cantidadController,
                      focusNode: focusNode,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Cant.",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onTap: () {
                        cantidadController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: cantidadController.text.length,
                        );
                      },
                      onSubmitted: (value) {
                        final val = int.tryParse(value);

                        if (val != null && val > 0) {
                          controller.actualizarCantidad(producto.id, val);

                          // Limpia el buscador ✔️
                          controller.filtrarProductos("");

                          // Opción: notificar a la pantalla principal para limpiar el controller
                          controller.limpiarBuscador?.call();
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
