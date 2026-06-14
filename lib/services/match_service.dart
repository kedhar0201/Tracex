import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  Stream<QuerySnapshot> getMyMatches() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('matches')
        .where('lostByUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }
}