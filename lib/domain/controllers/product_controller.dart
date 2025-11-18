import 'package:flutter/material.dart';
import '../../data/models/producto.dart';
import '../../data/services/local_storage_service.dart';

class ProductController extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();

  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  Map<int, int> _cantidades = {}; // id -> cantidad
  Set<int> _seleccionados = {}; // ids seleccionados
  bool _cargando = false;
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};


  List<Producto> get productos => _productosFiltrados;
  Map<int, int> get cantidades => _cantidades;
  Set<int> get seleccionados => _seleccionados;
  VoidCallback? limpiarBuscador;

  
  bool get cargando => _cargando;

  double get total {
    double suma = 0;
    for (var p in _productos) {
      if (_seleccionados.contains(p.id)) {
        suma += p.precio * (_cantidades[p.id] ?? 1);
      }
    }
    return suma;
  }

  TextEditingController getCantidadController(int id) {
    _controllers.putIfAbsent(
        id, () => TextEditingController(text: (cantidades[id] ?? 1).toString()));
    return _controllers[id]!;
  }

  FocusNode getCantidadFocusNode(int id) {
    _focusNodes.putIfAbsent(id, () => FocusNode());
    return _focusNodes[id]!;
  }

  Future<void> cargarProductos() async {
    _cargando = true;
    notifyListeners();

    _productos = await _storageService.cargarProductos();
    _productosFiltrados = List.from(_productos);

    _cargando = false;
    notifyListeners();
  }

  void filtrarProductos(String query) {
    if (query.isEmpty) {
      _productosFiltrados = List.from(_productos);
    } else {
      _productosFiltrados = _productos
          .where((p) =>
              p.nombre.toLowerCase().contains(query.toLowerCase().trim()))
          .toList();
    }
    notifyListeners();
  }

 void toggleSeleccion(int id) {
    if (seleccionados.contains(id)) {
      // deseleccionar
      seleccionados.remove(id);
      cantidades.remove(id);
      _controllers.remove(id);
      _focusNodes.remove(id);
      notifyListeners();
    } else {
      // seleccionar
      seleccionados.add(id);
      cantidades[id] = 1;

      _controllers[id] = TextEditingController(text: "1");
      _focusNodes[id] = FocusNode();

      notifyListeners();

      // Dar foco DESPUÉS de construir UI
      Future.microtask(() {
        _focusNodes[id]?.requestFocus();
        _controllers[id]?.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controllers[id]!.text.length,
        );
      });
    }
  }


  void actualizarCantidad(int id, int cantidad) {
    cantidades[id] = cantidad;
    notifyListeners();
  }


  Future<void> eliminarProducto(Producto p) async {
    await _storageService.eliminarProducto(p.id);
    _productos.removeWhere((prod) => prod.id == p.id);
    _productosFiltrados.removeWhere((prod) => prod.id == p.id);
    _seleccionados.remove(p.id);
    _cantidades.remove(p.id);
    notifyListeners();
  }

  void limpiarSeleccion() {
    _seleccionados.clear();
    _cantidades.clear();
    notifyListeners();
  }

  Future<void> exportarProductos() async {
    await _storageService.exportarProductos();
  }

  Future<void> importarProductos() async {
    await _storageService.importarProductos();
    await cargarProductos();
  }
  Future<void> actualizarProducto(Producto actualizado) async {
  await _storageService.actualizarProducto(actualizado);

  // Actualizar en memoria
  final index = _productos.indexWhere((p) => p.id == actualizado.id);
    if (index != -1) {
      _productos[index] = actualizado;
    }

    // Actualizar filtrados también
    final fIndex = _productosFiltrados.indexWhere((p) => p.id == actualizado.id);
    if (fIndex != -1) {
      _productosFiltrados[fIndex] = actualizado;
    }

    notifyListeners();
  }
  Future<void> agregarProductoConId(String nombre, double precio) async {
    await _storageService.agregarProductoConId(nombre, precio);
    await cargarProductos(); // recarga lista
  }

  Future<void> agregarProducto(String nombre, double precio) async {
    // Agrega el producto en el storage
    await _storageService.agregarProductoConId(nombre, precio);

    // Recarga la lista de productos
    await cargarProductos();
  }
}
