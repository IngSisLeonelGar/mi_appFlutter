class PreLista {
  final int id;
  final String nombre;
  final Map<int, int> productos;

  PreLista({
    required this.id,
    required this.nombre,
    required this.productos,
  });

  factory PreLista.fromJson(Map<String, dynamic> json) {
    return PreLista(
      id: json['id'],
      nombre: json['nombre'],
      productos: Map<int, int>.from(json['productos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'productos': productos,
    };
  }
}
