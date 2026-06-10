import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to send a message
  Future<void> sendMessage(String receiverId, String text, String senderId) async {
    final Timestamp timestamp = Timestamp.now();
    
    Message newMessage = Message(
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: timestamp,
    );

    // Construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
    List<String> ids = [senderId, receiverId];
    ids.sort(); // Sort ids so that chat room id is same for both sender and receiver
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Function to get messages stream
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
