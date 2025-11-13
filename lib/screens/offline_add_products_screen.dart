import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/local_storage_service.dart';

class AddProductScreen extends StatefulWidget {
  final Producto? producto; // Si es null => agregar, si no => editar
  const AddProductScreen({Key? key, this.producto}) : super(key: key);
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  final LocalStorageService _storageService = LocalStorageService();

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      // Rellenar campos si es edición
      _nombreController.text = widget.producto!.nombre;
      _precioController.text = widget.producto!.precio.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Producto' : 'Agregar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
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
                        if (_formKey.currentState!.validate()) {
                          setState(() => _guardando = true);

                          final nombre = _nombreController.text.trim();
                          final precio =
                              double.parse(_precioController.text.trim());

                          if (esEdicion) {
                            // Actualizar producto existente
                            final actualizado = Producto(
                              id: widget.producto!.id,
                              nombre: nombre,
                              precio: precio,
                            );
                            await _storageService.actualizarProducto(actualizado);
                          } else {
                            // Agregar nuevo producto
                            await _storageService.agregarProductoConId(
                                nombre, precio);
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
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}