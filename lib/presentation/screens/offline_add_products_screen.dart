import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/controllers/product_controller.dart';
import '../../data/models/producto.dart';

class AddProductScreen extends StatefulWidget {
  final Producto? producto;
  const AddProductScreen({super.key, this.producto});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    if (widget.producto != null) {
      _nombreController.text = widget.producto!.nombre;
      _precioController.text = widget.producto!.precio.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;
    final controller = context.read<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Producto' : 'Agregar Producto'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Ingrese un nombre' : null,
                ),

                TextFormField(
                  controller: _precioController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingrese un precio';
                    if (double.tryParse(v) == null) return 'Ingrese un número válido';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _guardando
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _guardando = true);

                          final nombre = _nombreController.text.trim();
                          final precio = double.parse(_precioController.text.trim());

                          if (esEdicion) {
                            final actualizado = Producto(
                              id: widget.producto!.id,
                              nombre: nombre,
                              precio: precio,
                            );
                            await controller.actualizarProducto(actualizado);
                          } else {
                            await controller.agregarProducto(nombre, precio);
                          }

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(esEdicion
                                    ? 'Producto actualizado'
                                    : 'Producto agregado'),
                              ),
                            );
                          }

                          setState(() => _guardando = false);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
