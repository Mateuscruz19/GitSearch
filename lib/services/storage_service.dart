abstract class StorageService {
  Future<void> saveJson(String key, Object value);

  Future<Object?> loadJson(String key);

  Future<void> remove(String key);
}
