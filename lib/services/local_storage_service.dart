import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/producto.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class LocalStorageService {
  // Obtener ruta del directorio local
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Obtener archivo local de productos
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/products.json');
  }

  // Cargar productos desde archivo local o assets si no existe
  Future<List<Producto>> cargarProductos() async {
    try {
      final file = await _localFile;

      // Si el archivo local no existe, crear uno desde assets
      if (!await file.exists()) {
        final data = await rootBundle.loadString('assets/products.json');
        await file.writeAsString(data);
      }

      final content = await file.readAsString();
      final List<dynamic> jsonData = json.decode(content);
      return jsonData.map((item) => Producto.fromMap(item)).toList();
    } catch (e) {
      print('Error al cargar productos: $e');
      return [];
    }
  }

  // Guardar lista de productos en archivo local
  Future<void> guardarProductos(List<Producto> productos) async {
    try {
      final file = await _localFile;
      final jsonString = json.encode(productos.map((p) => p.toMap()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error al guardar productos: $e');
    }
  }

  // Obtener el siguiente ID disponible (autoincremental)
  Future<int> obtenerSiguienteId() async {
    try {
      final productos = await cargarProductos();
      if (productos.isEmpty) return 1;

      final ids = productos.map((p) => p.id).toList();
      ids.sort();
      return ids.last + 1;
    } catch (e) {
      print('Error al obtener siguiente ID: $e');
      return 1;
    }
  }

  // Agregar producto con ID autoincremental
  Future<void> agregarProductoConId(String nombre, double precio) async {
    try {
      final nuevoId = await obtenerSiguienteId();
      final nuevo = Producto(id: nuevoId, nombre: nombre, precio: precio);

      final productos = await cargarProductos();
      productos.add(nuevo);
      await guardarProductos(productos);
    } catch (e) {
      print('Error al agregar producto con ID: $e');
    }
  }

  // Actualizar producto existente
  Future<void> actualizarProducto(Producto actualizado) async {
    try {
      final productos = await cargarProductos();
      final index = productos.indexWhere((p) => p.id == actualizado.id);
      if (index != -1) {
        productos[index] = actualizado;
        await guardarProductos(productos);
      } else {
        print('Producto con ID ${actualizado.id} no encontrado');
      }
    } catch (e) {
      print('Error al actualizar producto: $e');
    }
  }

  // Eliminar producto por ID
  Future<void> eliminarProducto(int id) async {
    try {
      final productos = await cargarProductos();
      productos.removeWhere((p) => p.id == id);
      await guardarProductos(productos);
    } catch (e) {
      print('Error al eliminar producto: $e');
    }
  }

  Future<void> exportarProductos() async {
    try {
      final file = await _localFile; // tu products.json
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Mis productos exportados',
        );
      } else {
        print('No hay archivo products.json para exportar.');
      }
    } catch (e) {
      print('Error al exportar productos: $e');
    }
  }

  // Importar productos desde un JSON externo
  Future<void> importarProductos() async {
    try {
      // Abrir selector de archivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final file = File(path);
        final content = await file.readAsString();

        // Decodificar JSON
        final List<dynamic> jsonData = json.decode(content);
        final productosImportados =
            jsonData.map((item) => Producto.fromMap(item)).toList();

        // Guardar en el archivo local (reemplaza todo)
        final localFile = await _localFile;
        final jsonString =
            json.encode(productosImportados.map((p) => p.toMap()).toList());
        await localFile.writeAsString(jsonString);
      } else {
        print('No se seleccionó ningún archivo.');
      }
    } catch (e) {
      print('Error al importar productos: $e');
    }
  }
}
