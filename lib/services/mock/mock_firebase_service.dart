class MockFirebaseService {
  static MockFirebaseService? _instance;

  static MockFirebaseService get instance {
    _instance ??= MockFirebaseService._();
    return _instance!;
  }

  MockFirebaseService._();

  MockFirestore get firestore => MockFirestore();
  MockFirebaseAuth get auth => MockFirebaseAuth();
  MockUser? get currentUser => null;
  bool get isUserLoggedIn => false;

  Future<void> initialize() async {
    // Mock initialization
  }
}

class MockFirestore {
  MockCollectionReference collection(String path) => MockCollectionReference();

  Future<void> enablePersistence(MockPersistenceSettings settings) async {
    // Mock implementation
  }

  set settings(MockSettings settings) {
    // Mock implementation
  }
}

class MockFirebaseAuth {
  MockUser? get currentUser => null;

  Future<MockUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return MockUserCredential();
  }

  Future<MockUserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return MockUserCredential();
  }

  Future<void> signOut() async {
    // Mock implementation
  }
}

class MockUser {
  String? get uid => 'mock-user-id';

  get email => null;
}

class MockUserCredential {
  MockUser? get user => MockUser();
}

class MockCollectionReference {
  MockDocumentReference doc(String documentId) => MockDocumentReference();

  Future<void> add(Map<String, dynamic> data) async {
    // Mock implementation
  }

  Stream<MockQuerySnapshot> snapshots() => Stream.value(MockQuerySnapshot());

  MockQuery where(String field, {Object? isEqualTo}) => MockQuery();
}

class MockDocumentReference {
  Future<void> set(Map<String, dynamic> data) async {
    // Mock implementation
  }

  Future<void> update(Map<String, dynamic> data) async {
    // Mock implementation
  }

  Future<void> delete() async {
    // Mock implementation
  }

  Future<MockDocumentSnapshot> get() async => MockDocumentSnapshot();

  Stream<MockDocumentSnapshot> snapshots() =>
      Stream.value(MockDocumentSnapshot());
}

class MockQuery {
  Stream<MockQuerySnapshot> snapshots() => Stream.value(MockQuerySnapshot());
  MockQuery orderBy(String field, {bool descending = false}) => this;
}

class MockQuerySnapshot {
  List<MockQueryDocumentSnapshot> get docs => [];
}

class MockDocumentSnapshot {
  bool get exists => false;
  Map<String, dynamic>? data() => null;
}

class MockQueryDocumentSnapshot extends MockDocumentSnapshot {
  String get id => 'mock-doc-id';
}

class MockPersistenceSettings {
  final bool synchronizeTabs;
  const MockPersistenceSettings({required this.synchronizeTabs});
}

class MockSettings {
  final bool persistenceEnabled;
  final int cacheSizeBytes;

  MockSettings({
    required this.persistenceEnabled,
    required this.cacheSizeBytes,
  });
}

class MockFieldValue {
  static MockFieldValue serverTimestamp() => MockFieldValue();
}
