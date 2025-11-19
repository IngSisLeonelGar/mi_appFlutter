import '../services/local_storage_service.dart';
import '../models/producto.dart';

class ProductRepository {
  final LocalStorageService storage;

  ProductRepository(this.storage);

  Future<List<Producto>> getProducts() => storage.readProducts();

  Future<void> addProduct(String nombre, double precio) =>
      storage.addProduct(nombre, precio);

  Future<void> updateProduct(Producto p) => storage.updateProduct(p);

  Future<void> deleteProduct(int id) => storage.deleteProduct(id);

  Future<void> exportProducts() => storage.exportProducts();

  Future<void> importProducts() => storage.importProducts();
}
