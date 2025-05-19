abstract class BaseRepositoryInterface<T> {
  Future<T?> get(String id);
  Future<List<T>> getAll();
  Future<T> create(T item);
  Future<T> update(T item);
  Future<bool> delete(String id);
} 