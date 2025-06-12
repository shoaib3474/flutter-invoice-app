import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gst_returns/firestore_gstr1_model.dart';
import '../models/gst_returns/firestore_gstr3b_model.dart';

class GSTReturnsRepository {
  final FirebaseFirestore _firestore;
  
  GSTReturnsRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  // GSTR1 Methods
  Future<FirestoreGSTR1> createGSTR1(FirestoreGSTR1 gstr1) async {
    try {
      await _firestore.collection('gstr1').doc(gstr1.id).set(gstr1.toFirestore());
      return gstr1;
    } catch (e) {
      throw Exception('Failed to create GSTR1: $e');
    }
  }
  
  Future<FirestoreGSTR1?> getGSTR1(String id) async {
    try {
      final doc = await _firestore.collection('gstr1').doc(id).get();
      if (doc.exists) {
        return FirestoreGSTR1.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get GSTR1: $e');
    }
  }
  
  Future<FirestoreGSTR1?> getGSTR1ByPeriod(String gstin, String returnPeriod) async {
    try {
      final snapshot = await _firestore
          .collection('gstr1')
          .where('gstin', isEqualTo: gstin)
          .where('return_period', isEqualTo: returnPeriod)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return FirestoreGSTR1.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get GSTR1 by period: $e');
    }
  }
  
  Future<void> updateGSTR1(FirestoreGSTR1 gstr1) async {
    try {
      await _firestore.collection('gstr1').doc(gstr1.id).update(gstr1.toFirestore());
    } catch (e) {
      throw Exception('Failed to update GSTR1: $e');
    }
  }
  
  Future<void> deleteGSTR1(String id) async {
    try {
      await _firestore.collection('gstr1').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete GSTR1: $e');
    }
  }
  
  Future<List<FirestoreGSTR1>> getAllGSTR1ByGstin(String gstin) async {
    try {
      final snapshot = await _firestore
          .collection('gstr1')
          .where('gstin', isEqualTo: gstin)
          .orderBy('return_period', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => FirestoreGSTR1.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all GSTR1 by GSTIN: $e');
    }
  }
  
  // GSTR3B Methods
  Future<FirestoreGSTR3B> createGSTR3B(FirestoreGSTR3B gstr3b) async {
    try {
      await _firestore.collection('gstr3b').doc(gstr3b.id).set(gstr3b.toFirestore());
      return gstr3b;
    } catch (e) {
      throw Exception('Failed to create GSTR3B: $e');
    }
  }
  
  Future<FirestoreGSTR3B?> getGSTR3B(String id) async {
    try {
      final doc = await _firestore.collection('gstr3b').doc(id).get();
      if (doc.exists) {
        return FirestoreGSTR3B.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get GSTR3B: $e');
    }
  }
  
  Future<FirestoreGSTR3B?> getGSTR3BByPeriod(String gstin, String returnPeriod) async {
    try {
      final snapshot = await _firestore
          .collection('gstr3b')
          .where('gstin', isEqualTo: gstin)
          .where('return_period', isEqualTo: returnPeriod)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return FirestoreGSTR3B.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get GSTR3B by period: $e');
    }
  }
  
  Future<void> updateGSTR3B(FirestoreGSTR3B gstr3b) async {
    try {
      await _firestore.collection('gstr3b').doc(gstr3b.id).update(gstr3b.toFirestore());
    } catch (e) {
      throw Exception('Failed to update GSTR3B: $e');
    }
  }
  
  Future<void> deleteGSTR3B(String id) async {
    try {
      await _firestore.collection('gstr3b').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete GSTR3B: $e');
    }
  }
  
  Future<List<FirestoreGSTR3B>> getAllGSTR3BByGstin(String gstin) async {
    try {
      final snapshot = await _firestore
          .collection('gstr3b')
          .where('gstin', isEqualTo: gstin)
          .orderBy('return_period', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => FirestoreGSTR3B.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all GSTR3B by GSTIN: $e');
    }
  }
  
  // Filing Status Methods
  Future<void> updateGSTR1FilingStatus(
    String id, 
    GSTR1Status status, 
    {DateTime? filingDate, String? acknowledgementNumber, String? errorMessage}
  ) async {
    try {
      final Map<String, dynamic> data = {
        'status': status.index,
        'updated_at': Timestamp.now(),
      };
      
      if (filingDate != null) {
        data['filing_date'] = Timestamp.fromDate(filingDate);
      }
      
      if (acknowledgementNumber != null) {
        data['acknowledgement_number'] = acknowledgementNumber;
      }
      
      if (errorMessage != null) {
        data['error_message'] = errorMessage;
      }
      
      await _firestore.collection('gstr1').doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update GSTR1 filing status: $e');
    }
  }
  
  Future<void> updateGSTR3BFilingStatus(
    String id, 
    GSTR3BStatus status, 
    {DateTime? filingDate, String? acknowledgementNumber, String? errorMessage}
  ) async {
    try {
      final Map<String, dynamic> data = {
        'status': status.index,
        'updated_at': Timestamp.now(),
      };
      
      if (filingDate != null) {
        data['filing_date'] = Timestamp.fromDate(filingDate);
      }
      
      if (acknowledgementNumber != null) {
        data['acknowledgement_number'] = acknowledgementNumber;
      }
      
      if (errorMessage != null) {
        data['error_message'] = errorMessage;
      }
      
      await _firestore.collection('gstr3b').doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update GSTR3B filing status: $e');
    }
  }
}
