import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DbService {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Crear perfil de usuario al loguearse
  Future<void> createUserProfile(User user) {
    return _firestore
        .collection('users')
        .doc(user.uid)
        .set({'email': user.email});
  }

  // 2. Stream del perfil (para leer el email)
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile() {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Stream de todos los registros de un jugador específico ordenado descendentemente
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
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs);
  }

  Future<void> addRecord(
    String sportId,
    String divisionId,
    String playerId,
    Map<String, dynamic> data,
  ) {
    // 1) Obtenemos el timestamp y el millis:
    final timestamp = data['timestamp'] as Timestamp;
    final millis = timestamp.millisecondsSinceEpoch;

    // 2) Nos aseguramos de tener también el campo 'fecha' en el Map:
    // 3) Guardamos con ID = millis, y dejamos intactos todos los campos de data
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
        .doc(millis.toString())
        .set({
      ...data,
      'fecha': data['fecha'], // conservar el campo legible
      'timestamp': timestamp, // conservar el Timestamp
    });
  }

  // Deportes
  Stream<List<String>> streamSports() => _firestore
      .collection('users')
      .doc(uid)
      .collection('sports')
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.id).toList());

  Future<void> addSport(String sport) => _firestore
      .collection('users')
      .doc(uid)
      .collection('sports')
      .doc(sport)
      .set({});

  // Divisiones
  Stream<List<String>> streamDivisions(String sportId) => _firestore
      .collection('users')
      .doc(uid)
      .collection('sports')
      .doc(sportId)
      .collection('divisions')
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.id).toList());

  Future<void> addDivision(String sportId, String division) => _firestore
      .collection('users')
      .doc(uid)
      .collection('sports')
      .doc(sportId)
      .collection('divisions')
      .doc(division)
      .set({});

  // Alumnos
  Stream<List<String>> streamPlayers(String sportId, String divisionId) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('sports')
          .doc(sportId)
          .collection('divisions')
          .doc(divisionId)
          .collection('players')
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.id).toList());

  Future<void> addPlayer(String sportId, String divisionId, String player) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('sports')
          .doc(sportId)
          .collection('divisions')
          .doc(divisionId)
          .collection('players')
          .doc(player)
          .set({});
}
