import 'package:flutter/foundation.dart';
import 'storage_interface.dart';

import 'web_storage.dart' if (dart.library.io) 'sqlite_storage.dart';

class StorageFactory {
  static StorageInterface createStorage() {
    if (kIsWeb) {
      return WebStorageImpl();
    } else {
      throw UnimplementedError('Native platform storage not implemented yet');
    }
  }
} 