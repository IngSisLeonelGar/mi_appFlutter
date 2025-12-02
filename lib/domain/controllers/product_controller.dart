import 'package:flutter/material.dart';
import '../../data/models/producto.dart';
import '../../data/repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository repo;

  List<Producto> _todos = [];
  List<Producto> _productos = [];
  List<Producto> get productos => _productos;

  bool cargando = false;

  Set<int> seleccionados = {};
  Map<int, int> cantidades = {};

  VoidCallback? limpiarBuscador;

  ProductController(this.repo);

  // ------------------------------
  // CARGAR PRODUCTOS
  // ------------------------------
  Future<void> cargarProductos() async {
    cargando = true;
    notifyListeners();

    _todos = await repo.getProducts();
    _productos = List.from(_todos);

    cargando = false;
    notifyListeners();
  }

  // ------------------------------
  // AGREGAR PRODUCTO
  // ------------------------------
  Future<void> agregarProducto(String nombre, double precio) async {
    await repo.addProduct(nombre, precio);
    await cargarProductos();
  }

  // ------------------------------
  // ACTUALIZAR PRODUCTO
  // ------------------------------
  Future<void> actualizarProducto(Producto p) async {
    await repo.updateProduct(p);
    await cargarProductos();
  }

  // ------------------------------
  // ELIMINAR PRODUCTO
  // ------------------------------
  Future<void> eliminarProducto(Producto p) async {
    await repo.deleteProduct(p.id);
    await cargarProductos();
  }

  // ------------------------------
  // FILTRAR PRODUCTOS
  // ------------------------------
  void filtrarProductos(String texto) {
    if (texto.isEmpty) {
      _productos = List.from(_todos);
    } else {
      texto = texto.toLowerCase();
      _productos = _todos.where((p) {
        return p.nombre.toLowerCase().contains(texto) ||
            p.precio.toString().contains(texto);
      }).toList();
    }
    notifyListeners();
  }

  // ------------------------------
  // SELECCIÓN
  // ------------------------------
  void toggleSeleccion(int id) {
  if (seleccionados.contains(id)) {
    seleccionados.remove(id);
    cantidades.remove(id);
  } else {
    seleccionados.add(id);
    // Solo asigna 1 si aún no existe
    cantidades.putIfAbsent(id, () => 1);
  }
  notifyListeners();
}


  void actualizarCantidad(int id, int cant) {
    if (cant <= 0) return;
    cantidades[id] = cant;
    notifyListeners();
  }

  void limpiarSeleccion() {
    seleccionados.clear();
    cantidades.clear();
    notifyListeners();
  }

  // ------------------------------
  // TOTAL
  // ------------------------------
  double get total {
    double suma = 0;
    for (final id in seleccionados) {
      final prod = _todos.firstWhere((p) => p.id == id);
      suma += prod.precio * (cantidades[id] ?? 1);
    }
    return suma;
  }

  // ------------------------------
  // IMPORTAR / EXPORTAR (vacío offline)
  // ------------------------------
  Future<void> exportarProductos() async {}
  Future<void> importarProductos() async {
    await cargarProductos();
  } 

  // ------------------------------
  // CONTROLADORES DE CANTIDAD
  // ------------------------------
  final Map<int, TextEditingController> _cantidadControllers = {};
  final Map<int, FocusNode> _cantidadFocusNodes = {};

  TextEditingController getCantidadController(int id) {
    if (!_cantidadControllers.containsKey(id)) {
      _cantidadControllers[id] =
          TextEditingController(text: (cantidades[id] ?? 1).toString());
    }
    return _cantidadControllers[id]!;
  }

  FocusNode getCantidadFocusNode(int id) {
    if (!_cantidadFocusNodes.containsKey(id)) {
      _cantidadFocusNodes[id] = FocusNode();
    }
    return _cantidadFocusNodes[id]!;
  }
}
