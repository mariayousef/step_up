import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_up/app_colors.dart';
import 'package:step_up/models/doctor_model.dart';
import 'package:step_up/models/message_model.dart';
import 'package:step_up/services/chat_service.dart';

import 'package:step_up/services/api_service.dart';

class DoctorChatScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorChatScreen({super.key, required this.doctor});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getUser();
    String? foundId = user?['id']?.toString() ?? 
                     user?['phone_number']?.toString();
    
    // If ID is still unknown, try to fetch it from their own appointment records
    if (foundId == null || foundId == 'unknown_parent' || foundId.isEmpty) {
      try {
        final response = await ApiService.getJson('/api/appointments', authorized: true);
        if (response['data'] is List && (response['data'] as List).isNotEmpty) {
          final first = response['data'][0];
          foundId = first['parent_id']?.toString() ?? 
                    (first['parent'] is Map ? first['parent']['id']?.toString() : null);
          
          if (foundId != null) {
            // Save it for next time
            await ApiService.saveUser({'id': foundId});
          }
        }
      } catch (e) {
        debugPrint("Chat ID discovery error: $e");
      }
    }

    if (mounted) {
      setState(() {
        _currentUserId = foundId ?? 'unknown_parent';
      });
      debugPrint("PARENT CHAT LOADED: Parent $_currentUserId -> Doctor ${widget.doctor.id}");
      
      if (_currentUserId.isNotEmpty && _currentUserId != 'unknown_parent') {
        List<String> ids = [_currentUserId, widget.doctor.id];
        ids.sort();
        ChatService.currentOpenRoom = ids.join('_');
        _chatService.markRoomAsRead(_currentUserId, widget.doctor.id);
      }
    }
  }

  @override
  void dispose() {
    ChatService.currentOpenRoom = "";
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId.isEmpty) return;
    
    final text = _messageController.text.trim();
    _messageController.clear();
    
    await _chatService.sendMessage(widget.doctor.id.toString(), text, _currentUserId);
  }

  String _formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    String hourStr = hour.toString().padLeft(2, '0');
    String minuteStr = dateTime.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textMain),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(_currentUserId, widget.doctor.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messagesDocs = snapshot.data!.docs;
                if (messagesDocs.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hi!'));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messagesDocs.length,
                  itemBuilder: (context, index) {
                    final data = messagesDocs[index].data() as Map<String, dynamic>;
                    final message = Message.fromMap(data);
                    
                    final isMe = message.senderId == _currentUserId;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : AppColors.textMain,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
