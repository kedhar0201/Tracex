import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  // Send a message
  Future<void> sendMessage(String matchId, String message) async {
    await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .add({
      'senderId': currentUid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String matchId) {
    return _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // Initialize chat for a match
  Future<void> initializeChat(String matchId, String lostByUid, String foundByUid) async {
    await _firestore.collection('chats').doc(matchId).set({
      'participants': [lostByUid, foundByUid],
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}