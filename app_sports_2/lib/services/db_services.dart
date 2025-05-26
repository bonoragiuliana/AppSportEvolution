import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DbService {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream de todos los registros de un jugador específico
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamRecords(
      String sportId, String divisionId, String playerId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('sports')
        .doc(sportId)
        .collection('divisions')
        .doc(divisionId)
        .collection('players')
        .doc(playerId)
        .collection('records')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs);
  }

  Future<void> addRecord(
    String sportId,
    String divisionId,
    String playerId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sports')
        .doc(sportId)
        .collection('divisions')
        .doc(divisionId)
        .collection('players')
        .doc(playerId)
        .collection('records')
        .add(data);
  }
}
