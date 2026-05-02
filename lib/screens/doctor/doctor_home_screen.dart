import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:step_up/screens/doctor/patient_details_screen.dart';
import 'package:step_up/screens/doctor/chat_room_screen.dart';
import 'package:step_up/screens/doctor/doctor_profile_screen.dart';
import 'package:step_up/screens/doctor/doctor_notifications_screen.dart';
import 'package:step_up/screens/doctor/tools/calculator_screen.dart';
import 'package:step_up/screens/doctor/tools/note_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardTab(),
      _buildCasesTab(),
      _buildChatsTab(),
      _buildToolsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Clinic', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
        ),
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorNotificationsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorProfileScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00796B),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt),
              label: 'Cases',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'Tools',
            ),
          ],
        ),
      ),
    );
  }

  // ============== Tabs ==============

  Widget _buildDashboardTab() {
    return FadeIn(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Dr. Ahmed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            const Text(
              'Here is a quick summary of your activity',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(child: _buildStatCard('Active Cases', '12', Icons.people, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('New Messages', '3', Icons.message, Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Parent Requests', '1', Icons.person_add, Colors.redAccent)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Daily Notes', '2', Icons.note, Colors.green)),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text('Notifications & Action Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                title: const Text('New connection request from parent "Omar"'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorNotificationsScreen()));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCasesTab() {
    return FadeIn(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE0F2F1),
                child: Icon(Icons.child_care, color: Color(0xFF00796B)),
              ),
              title: Text('Child ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Age: 4 years | Good progress'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientDetailsScreen(patientName: 'Child ${index + 1}')),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatsTab() {
    return FadeIn(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2, 
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatRoomScreen(parentName: 'Parent ${index + 1}')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFB2DFDB),
                    child: Icon(Icons.person, color: Color(0xFF00796B)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Parent ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('Question regarding the exercises...', style: TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('10:30 PM', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 5),
                      if (index == 0) 
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10)),
                        )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolsTab() {
    return FadeIn(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Quick Tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildToolCard(
            Icons.edit_document, 
            'Add Note', 
            'Securely save local notes.',
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteScreen())),
          ),
          _buildToolCard(
            Icons.calculate, 
            'Ideal Weight / Age Calculator', 
            'Calculate progress based on DS curves.',
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF33691E), size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
