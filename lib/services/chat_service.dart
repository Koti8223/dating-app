import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generate unique chat room ID from two user IDs
  String getChatRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'text',
  }) async {
    final chatRoomId = getChatRoomId(senderId, receiverId);
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      createdAt: DateTime.now(),
    );

    // Save message to chat room
    await _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // Update last message in chat room
    await _db.collection('chats').doc(chatRoomId).set({
      'lastMessage': content,
      'lastMessageTime': DateTime.now().toIso8601String(),
      'participants': [senderId, receiverId],
      'lastSenderId': senderId,
    });
  }

  // Get real time messages stream
  Stream<List<MessageModel>> getMessages({
    required String senderId,
    required String receiverId,
  }) {
    final chatRoomId = getChatRoomId(senderId, receiverId);

    return _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  // Get all chat rooms for a user
  Stream<List<Map<String, dynamic>>> getUserChats(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Mark messages as read
  Future<void> markAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    final chatRoomId = getChatRoomId(senderId, receiverId);
    final unread = await _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: receiverId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unread.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}
