import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:mi_app/data/models/prelista.dart';

class PreListaController extends ChangeNotifier {
  List<PreLista> preListas = [];

  /// Cargar desde JSON local
  Future<void> cargarPreListas() async {
    try {
      final raw = await rootBundle.loadString('assets/pre_listas.json');
      final data = json.decode(raw) as List;
      preListas = data.map((e) => PreLista.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print("Error cargando prelistas: $e");
    }
  }

  /// Guardar pre-lista en memoria
  void agregarPreLista(PreLista p) {
    preListas.add(p);
    notifyListeners();
    // aquí podrías llamar a guardar en JSON / archivo local si quieres persistir
  }

  /// Actualizar pre-lista existente
  void actualizarPreLista(PreLista p) {
    final index = preListas.indexWhere((pl) => pl.id == p.id);
    if (index != -1) {
      preListas[index] = p;
      notifyListeners();
    }
  }

  /// Eliminar pre-lista
  void eliminarPreLista(int id) {
    preListas.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Limpiar todas las pre-listas
  void limpiarPreListas() {
    preListas.clear();
    notifyListeners();
  }
}
