import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_up/screens/doctor/patient_details_screen.dart';
import 'package:step_up/screens/doctor/chat_room_screen.dart';
import 'package:step_up/screens/doctor/doctor_profile_screen.dart';
import 'package:step_up/screens/doctor/doctor_notifications_screen.dart';
import 'package:step_up/screens/doctor/tools/calculator_screen.dart';
import 'package:step_up/screens/doctor/tools/note_screen.dart';
import 'package:step_up/services/doctor_service.dart';
import 'package:step_up/models/appointment_model.dart';
import 'package:step_up/services/api_service.dart';
import 'package:step_up/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;
  List<Appointment> _appointments = [];
  List<dynamic> _recentNotes = [];
  bool _isLoadingAppointments = false;
  String _currentDoctorId = '';
  String _doctorName = 'Doctor';
  
  bool _hasUnreadMessages = false;
  Map<String, int> _unreadCounts = {}; // parentId -> unreadCount
  final DateTime _appOpenTime = DateTime.now();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<StreamSubscription> _chatSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadInitialData();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  @override
  void dispose() {
    for (var sub in _chatSubscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadDoctorData();
    await _fetchAppointments();
    await _loadRecentNotes();
  }

  Future<void> _loadDoctorData() async {
    final user = await ApiService.getUser();
    if (user != null && mounted) {
      setState(() {
        _currentDoctorId = user['id']?.toString() ?? 
                           user['phone_number']?.toString() ?? 
                           '';
        _doctorName = user['name'] ?? user['full_name'] ?? 'Doctor';
      });
      if (_currentDoctorId.isNotEmpty) {
        _setupMessageListeners();
      }
    }
  }

  Future<void> _loadRecentNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('doctor_notes');
    if (notesJson != null && mounted) {
      final List<dynamic> decodedList = jsonDecode(notesJson);
      setState(() {
        // Take top 3 notes
        _recentNotes = decodedList.take(3).toList();
      });
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoadingAppointments = true);
    try {
      final list = await DoctorService.fetchDoctorAppointments();
      if (mounted) {
        setState(() {
          _appointments = list;
          _isLoadingAppointments = false;
        });

        // DISCOVER DOCTOR ID if missing
        if (_currentDoctorId.isEmpty && list.isNotEmpty) {
          final first = list[0];
          // Try to get doctor id from the first appointment object
          final discoveredId = first.doctor?.id?.toString();
          if (discoveredId != null && discoveredId.isNotEmpty) {
            setState(() => _currentDoctorId = discoveredId);
            await ApiService.saveUser({'id': discoveredId, 'name': _doctorName});
            debugPrint("DOCTOR ID DISCOVERED FROM APPOINTMENTS: $discoveredId");
            _setupMessageListeners();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAppointments = false);
      }
    }
  }

  void _setupMessageListeners() {
    if (_currentDoctorId.isEmpty) return;

    for (var sub in _chatSubscriptions) {
      sub.cancel();
    }
    _chatSubscriptions.clear();

    var sub = FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('participants', arrayContains: _currentDoctorId)
        .snapshots()
        .listen((snapshot) {
      bool anyUnread = false;
      Map<String, int> newCounts = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount = data['unreadCount_$_currentDoctorId'] ?? 0;
        
        // Extract parentId from roomId (roomId is built by sorting doctorId and parentId)
        String roomId = doc.id;
        String pId = roomId.replaceFirst(_currentDoctorId, '').replaceAll('_', '');
        
        if (pId.isNotEmpty) {
          newCounts[pId] = (unreadCount as num).toInt();
        }

        if (unreadCount > 0) {
          anyUnread = true;
          
          // Show notification only if it's a new or modified unread state, AND not in the open room
          if (ChatService.currentOpenRoom == roomId) {
            // Already in room, mark as read automatically to avoid ghost unread badges
            ChatService().markRoomAsRead(_currentDoctorId, pId);
          } else {
             // We could check if it's a new change to avoid spamming
             bool isNew = snapshot.docChanges.any((c) => c.doc.id == roomId && (c.type == DocumentChangeType.added || c.type == DocumentChangeType.modified));
             if (isNew) {
               String msgText = data['lastMessage'] ?? 'You received a new message';
               if (_currentIndex != 2) {
                 _showNotification('New Message', msgText);
               }
             }
          }
        }
      }

      if (mounted) {
        setState(() {
          _unreadCounts = newCounts;
          _hasUnreadMessages = anyUnread && _currentIndex != 2;
        });
      }
    });

    _chatSubscriptions.add(sub);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardTab(),
      _buildCasesTab(),
      _buildChatsTab(),
      _buildToolsTab(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentIndex = 0;
          if (_currentIndex == 2) {
            _hasUnreadMessages = false;
          }
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: screens[_currentIndex],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome,', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              Text('Dr. $_doctorName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1A1A1A))),
            ],
          ),
          Row(
            children: [
              _buildAppBarIcon(Icons.notifications_none, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorNotificationsScreen()));
              }),
              const SizedBox(width: 12),
              _buildAppBarIcon(Icons.person_outline, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorProfileScreen()));
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF00796B), size: 24),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
          _buildNavItem(1, Icons.people_rounded, 'Cases'),
          _buildNavItem(2, Icons.chat_bubble_rounded, 'Chats'),
          _buildNavItem(3, Icons.medical_services_rounded, 'Tools'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index == 2) {
            _hasUnreadMessages = false; // Clear badge when chats tab is opened
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00796B).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: isSelected ? const Color(0xFF00796B) : Colors.grey, size: 26),
                if (index == 2 && _hasUnreadMessages)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    int totalUnread = _unreadCounts.values.fold(0, (sum, count) => sum + count);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _buildQuickActions(totalUnread),
          ),
          const SizedBox(height: 25),
          const Text('Your Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildStatCard('Active Cases', _appointments.length.toString(), Icons.people, const Color(0xFF2196F3))),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard('Messages', totalUnread.toString(), Icons.message, const Color(0xFFFF9800))),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Private Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteScreen())).then((_) => _loadRecentNotes()),
                child: const Text('View All', style: TextStyle(color: Color(0xFF00796B))),
              )
            ],
          ),
          const SizedBox(height: 10),
          _buildRecentNotesSection(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(int totalUnread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(Icons.add_task_rounded, 'New Case', Colors.teal, () => setState(() => _currentIndex = 1)),
            _buildActionItem(Icons.chat_rounded, 'Messages', Colors.blue, () => setState(() => _currentIndex = 2), badgeCount: totalUnread),
            _buildActionItem(Icons.history_edu_rounded, 'Add Note', Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteScreen())).then((_) => _loadRecentNotes())),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap, {int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : badgeCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecentNotesSection() {
    if (_recentNotes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: const Center(child: Text('No notes found. Tap "Add Note" to start.', style: TextStyle(color: Colors.grey))),
      );
    }
    return Column(
      children: _recentNotes.map((note) => _buildDashboardNoteItem(note['text'] ?? '')).toList(),
    );
  }

  Widget _buildDashboardNoteItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin, color: Color(0xFF00796B), size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF333333)))),
        ],
      ),
    );
  }

  Widget _buildCasesTab() {
    return RefreshIndicator(
      onRefresh: _fetchAppointments,
      color: const Color(0xFF00796B),
      child: _isLoadingAppointments
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)))
          : _appointments.isEmpty
              ? _buildEmptyState('No active cases yet', Icons.people_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
                    return FadeInLeft(
                      delay: Duration(milliseconds: 100 * index),
                      child: _buildCaseCard(appointment),
                    );
                  },
                ),
    );
  }

  Widget _buildCaseCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.child_care, color: Color(0xFF00796B), size: 30),
        ),
        title: Text(appointment.childName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Parent: ${appointment.parent?.name ?? "N/A"}\nReason: ${appointment.description}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailsScreen(
                appointment: appointment,
                doctorId: _currentDoctorId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatsTab() {
    return _appointments.isEmpty
        ? _buildEmptyState('No active chats yet', Icons.chat_bubble_outline)
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _appointments.length,
            itemBuilder: (context, index) {
              final appointment = _appointments[index];
              final parentId = appointment.parent?.id?.toString() ?? appointment.parent?.phoneNumber ?? '';
              final unread = _unreadCounts[parentId] ?? 0;
              return FadeInRight(
                delay: Duration(milliseconds: 100 * index),
                child: _buildChatListItem(appointment, unreadCount: unread),
              );
            },
          );
  }

  Widget _buildChatListItem(Appointment appointment, {int unreadCount = 0}) {
    final parentName = appointment.parent?.name ?? 'Parent';
    final parentId = appointment.parent?.id?.toString() ?? appointment.parent?.phoneNumber ?? 'N/A';

    return GestureDetector(
      onTap: () {
        if (_currentDoctorId.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              parentId: parentId,
              parentName: parentName,
              doctorId: _currentDoctorId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const CircleAvatar(radius: 25, backgroundColor: Color(0xFFB2DFDB), child: Icon(Icons.person, color: Color(0xFF00796B))),
                if (unreadCount > 0)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text('Discussing the latest check-up...', style: TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1),
                ],
              ),
            ),
            const Text('Now', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Quick Tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildToolCard(
          Icons.edit_document, 
          'Add Note', 
          'Securely save local private notes.',
          const Color(0xFF4CAF50),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteScreen())).then((_) => _loadRecentNotes()),
        ),
        _buildToolCard(
          Icons.calculate, 
          'Progress Calculator', 
          'Calculate progress based on DS curves.',
          const Color(0xFF2196F3),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorScreen())),
        ),
      ],
    );
  }

  Widget _buildToolCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
