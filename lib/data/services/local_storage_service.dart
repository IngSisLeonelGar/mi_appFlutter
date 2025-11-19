import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/producto.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class LocalStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/products.json');
  }

  // Leer productos desde storage o desde assets la primera vez
  Future<List<Producto>> readProducts() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        final data = await rootBundle.loadString('assets/products.json');
        await file.writeAsString(data);
      }

      final content = await file.readAsString();
      final List<dynamic> jsonData = json.decode(content);
      return jsonData.map((item) => Producto.fromMap(item)).toList();

    } catch (e) {
      print('Error al leer productos: $e');
      return [];
    }
  }

  Future<void> saveProducts(List<Producto> productos) async {
    try {
      final file = await _localFile;
      final jsonString = json.encode(productos.map((p) => p.toMap()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error al guardar productos: $e');
    }
  }

  Future<int> getNextId() async {
    final productos = await readProducts();
    if (productos.isEmpty) return 1;

    final ids = productos.map((p) => p.id).toList();
    ids.sort();
    return ids.last + 1;
  }

  Future<void> addProduct(String nombre, double precio) async {
    final newId = await getNextId();
    final nuevo = Producto(id: newId, nombre: nombre, precio: precio);
    final productos = await readProducts();

    productos.add(nuevo);
    await saveProducts(productos);
  }

  Future<void> updateProduct(Producto actualizado) async {
    final productos = await readProducts();
    final index = productos.indexWhere((p) => p.id == actualizado.id);

    if (index != -1) {
      productos[index] = actualizado;
      await saveProducts(productos);
    }
  }

  Future<void> deleteProduct(int id) async {
    final productos = await readProducts();
    productos.removeWhere((p) => p.id == id);
    await saveProducts(productos);
  }

  Future<void> exportProducts() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Mis productos exportados',
        );
      }
    } catch (e) {
      print('Error exportando productos: $e');
    }
  }

  Future<void> importProducts() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      final List<dynamic> jsonData = json.decode(content);
      final data =
          jsonData.map((item) => Producto.fromMap(item)).toList();

      final localFile = await _localFile;
      await localFile.writeAsString(
        json.encode(data.map((p) => p.toMap()).toList()),
      );
    } catch (e) {
      print('Error importando productos: $e');
    }
  }
}
