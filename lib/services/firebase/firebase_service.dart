import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  User? get currentUser => _auth.currentUser;
  bool get isUserLoggedIn => _auth.currentUser != null;

  // Firebase Initialization
  Future<void> initialize() async {
    await _firestore
        .enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    )
        .catchError((e) {
      if (kDebugMode) print('Error enabling persistence: $e');
    });

    _firestore.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 104857600, // 100 MB
    );
  }

  // Authentication Methods
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }

  Future<void> deleteUserAccount() async {
    await currentUser?.delete();
  }

  // Firestore CRUD Operations
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  Future<void> setDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).set(data);
  }

  Future<void> updateDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  Future<DocumentSnapshot> getDocument(
      String collection, String documentId) async {
    return await _firestore.collection(collection).doc(documentId).get();
  }

  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Future<List<DocumentSnapshot>> getAllDocuments(String collection) async {
    final querySnapshot = await _firestore.collection(collection).get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> getUserSubCollection(
      String subCollection) async {
    final String userId = currentUser?.uid ?? 'anonymous';
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(subCollection)
        .get();
    return snapshot.docs;
  }

  // Current User Firestore Data
  Future<DocumentSnapshot?> getCurrentUserData() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateCurrentUserData(Map<String, dynamic> data) async {
    final uid = currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update(data);
    }
  }

  // GST-specific Methods
  Future<void> saveGSTReturn(
      String gstin, String period, Map<String, dynamic> data) async {
    final String userId = currentUser?.uid ?? 'anonymous';
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('gst_returns')
        .doc('$gstin-$period')
        .set({
      'gstin': gstin,
      'period': period,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getGSTReturns(String gstin) {
    final String userId = currentUser?.uid ?? 'anonymous';
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('gst_returns')
        .where('gstin', isEqualTo: gstin)
        .snapshots();
  }

  // Invoice Methods
  Future<void> saveInvoice(Map<String, dynamic> invoiceData) async {
    final String userId = currentUser?.uid ?? 'anonymous';
    final String invoiceId = invoiceData['invoiceNumber'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('invoices')
        .doc(invoiceId)
        .set({
      ...invoiceData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getInvoices() {
    final String userId = currentUser?.uid ?? 'anonymous';
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('invoices')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // GSTIN Tracking Methods
  Future<void> saveGSTINTracking(
      String gstin, Map<String, dynamic> data) async {
    final String userId = currentUser?.uid ?? 'anonymous';
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('gstin_tracking')
        .doc(gstin)
        .set({
      'gstin': gstin,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> getGSTINTracking(String gstin) {
    final String userId = currentUser?.uid ?? 'anonymous';
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('gstin_tracking')
        .doc(gstin)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> queryDocuments(
    String collection, {
    required List<List> whereConditions,
    required String orderBy,
    required bool descending,
  }) async {
    // Implement actual logic here
    // Dummy return for now
    return [];
  }
}
