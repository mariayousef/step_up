import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_up/services/chat_service.dart';
import 'package:step_up/models/message_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final String parentId;
  final String parentName;
  final String doctorId;

  const ChatRoomScreen({
    super.key,
    required this.parentId,
    required this.parentName,
    required this.doctorId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    debugPrint("CHAT ROOM START: Doctor ${widget.doctorId} -> Parent ${widget.parentId}");
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String text = _messageController.text.trim();
      _messageController.clear();
      FocusScope.of(context).unfocus();

      await _chatService.sendMessage(widget.parentId, text, widget.doctorId);
    }
  }

  void _sendAttachment(String textMessage) async {
    // For simplicity, attachments are sent as text messages for now
    await _chatService.sendMessage(widget.parentId, textMessage, widget.doctorId);
  }

  // دالة تشغيل منتقي الصور
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // إغلاق النافذة السفلية أولاً
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null && mounted) {
        _sendAttachment('📷 Image Sent: ${image.name}');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // دالة إرسال مستند
  void _pickDocument() {
    Navigator.pop(context); // إغلاق النافذة السفلية أولاً
    _sendAttachment('📄 Document Sent: file_name.pdf');
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 180, // قللنا الارتفاع بعد مسح الروشتة
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share Attachment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachOption(Icons.image, 'Gallery', Colors.purple, () => _pickImage(ImageSource.gallery)),
                  _buildAttachOption(Icons.camera_alt, 'Camera', Colors.redAccent, () => _pickImage(ImageSource.camera)),
                  _buildAttachOption(Icons.insert_drive_file, 'Document', Colors.blue, _pickDocument),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    bool isAttachment = msg['type'] == 'attachment';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00796B) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          msg['text'],
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontStyle: isAttachment ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFB2DFDB),
              child: Icon(Icons.person, color: Color(0xFF00796B), size: 20),
            ),
            const SizedBox(width: 10),
            Text(widget.parentName, style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.doctorId, widget.parentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet. Start the conversation!'));
                }

                final messagesDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: messagesDocs.length,
                  itemBuilder: (context, index) {
                    var data = messagesDocs[index].data() as Map<String, dynamic>;
                    final message = Message.fromMap(data);
                    
                    Map<String, dynamic> msg = {
                      'text': message.text,
                      'isMe': message.senderId == widget.doctorId,
                      'type': message.text.contains('📷') || message.text.contains('📄') ? 'attachment' : 'text',
                    };
                    return _buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey), 
                  onPressed: () => _showAttachmentOptions(context), 
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00796B)),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
    );
  }
}
