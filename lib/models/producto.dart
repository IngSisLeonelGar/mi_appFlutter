class Producto {
  final int id;
  final String nombre;
  final double precio;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
  });

  // Convertir Producto a Map (para guardar en JSON o Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id' : id,  
      'nombre': nombre,
      'precio': precio,
    };
  }

  // Crear Producto desde Map (leer de JSON o Firebase)
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] is int ? map['id']: int.tryParse(map['id'].toString()) ?? 0,
      nombre: map['nombre'] ?? '',
      precio: map['precio'] != null
          ? double.tryParse(map['precio'].toString()) ?? 0.0
          : 0.0,
    );
  }

  // Convertir Producto a JSON string
  String toJson() => toMap().toString();

}
