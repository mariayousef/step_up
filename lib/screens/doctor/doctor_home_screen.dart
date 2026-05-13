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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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
        _doctorName = user['name'] ?? 'Doctor';
      });
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
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAppointments = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardTab(),
      _buildCasesTab(),
      _buildChatsTab(),
      _buildToolsTab(),
    ];

    return Scaffold(
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
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00796B).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00796B) : Colors.grey, size: 26),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _buildQuickActions(),
          ),
          const SizedBox(height: 25),
          const Text('Your Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildStatCard('Active Cases', _appointments.length.toString(), Icons.people, const Color(0xFF2196F3))),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard('Messages', '0', Icons.message, const Color(0xFFFF9800))),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(Icons.add_task_rounded, 'New Case', Colors.teal, () => setState(() => _currentIndex = 1)),
            _buildActionItem(Icons.chat_rounded, 'Messages', Colors.blue, () => setState(() => _currentIndex = 2)),
            _buildActionItem(Icons.history_edu_rounded, 'Add Note', Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteScreen())).then((_) => _loadRecentNotes())),
            _buildActionItem(Icons.settings_rounded, 'Settings', Colors.grey, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
            MaterialPageRoute(builder: (context) => PatientDetailsScreen(appointment: appointment)),
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
              return FadeInRight(
                delay: Duration(milliseconds: 100 * index),
                child: _buildChatListItem(appointment),
              );
            },
          );
  }

  Widget _buildChatListItem(Appointment appointment) {
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
            const CircleAvatar(radius: 25, backgroundColor: Color(0xFFB2DFDB), child: Icon(Icons.person, color: Color(0xFF00796B))),
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
