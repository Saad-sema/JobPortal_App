import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// -----------------------------
  /// Get or Create Chat (WITH NAMES)
  /// -----------------------------
  Future<String> getOrCreateChat({
    required String seekerId,
    required String employerId,
  }) async {
    final existing = await _firestore
        .collection('chats')
        .where('participants', arrayContains: seekerId)
        .get();

    for (final doc in existing.docs) {
      final participants =
      List<String>.from(doc['participants']);
      if (participants.contains(employerId)) {
        return doc.id;
      }
    }

    // Fetch names once
    final seekerDoc = await _firestore
        .collection('users')
        .doc(seekerId)
        .get();

    final employerDoc = await _firestore
        .collection('users')
        .doc(employerId)
        .get();

    final seekerName =
        seekerDoc.data()?['name'] ?? 'Seeker';

    final employerName =
        employerDoc.data()?['companyName'] ??
            employerDoc.data()?['name'] ??
            'Employer';

    final chatDoc = await _firestore.collection('chats').add({
      'participants': [seekerId, employerId],
      'participantNames': {
        seekerId: seekerName,
        employerId: employerName,
      },
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // System message
    await chatDoc.collection('messages').add({
      'senderId': 'system',
      'text': 'Chat started',
      'sentAt': FieldValue.serverTimestamp(),
    });

    return chatDoc.id;
  }

  /// -----------------------------
  /// Send Message
  /// -----------------------------
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// -----------------------------
  /// Message Stream
  /// -----------------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(
      String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots();
  }
}
