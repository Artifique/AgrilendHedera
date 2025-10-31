// Fallback shim for FlutterSecureStorage to allow compilation if the package
// `flutter_secure_storage` isn't installed yet in the environment.
// IMPORTANT: This is a temporary no-op implementation. You should run
// `flutter pub get` to install the real package and remove/replace this shim.

class FlutterSecureStorage {
  const FlutterSecureStorage();

  Future<void> write({required String key, required String? value}) async {
    // no-op fallback
  }

  Future<String?> read({required String key}) async {
    return null;
  }

  Future<void> delete({required String key}) async {
    // no-op
  }
}
