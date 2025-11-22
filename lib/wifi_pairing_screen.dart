// wifi_pairing_screen.dart
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:step_up/app_colors.dart';

class WifiPairingScreen extends StatefulWidget {
  const WifiPairingScreen({super.key});

  @override
  State<WifiPairingScreen> createState() => _WifiPairingScreenState();
}

class _WifiPairingScreenState extends State<WifiPairingScreen> {
  List<WifiNetwork> wifiNetworks = [];
  String? selectedSSID;
  final passwordController = TextEditingController();
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    loadWifiNetworks();
  }

  void loadWifiNetworks() async {
    List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      wifiNetworks = networks;
    });
  }

  void connectToWifi() async {
    if (selectedSSID == null || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a network and enter password')),
      );
      return;
    }

    setState(() {
      isConnecting = true;
    });

    bool connected = await WiFiForIoTPlugin.connect(
      selectedSSID!,
      password: passwordController.text,
      security: NetworkSecurity.WPA,
    );

    setState(() {
      isConnecting = false;
    });

    if (connected) {
      // الاتصال ناجح، نذهب مباشرة للـ HomeScreen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // فشل الاتصال
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect')),
      );
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Pairing'),
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.wifi, size: 100, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              'Select a Wi-Fi network to pair:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: wifiNetworks.length,
                itemBuilder: (context, index) {
                  final network = wifiNetworks[index];
                  return ListTile(
                    title: Text(network.ssid ?? 'Unknown SSID'),
                    leading: Radio<String>(
                      value: network.ssid ?? '',
                      groupValue: selectedSSID,
                      onChanged: (value) {
                        setState(() {
                          selectedSSID = value;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (selectedSSID != null)
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),
            isConnecting
                ? const CircularProgressIndicator(color: AppColors.primary)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: connectToWifi,
              child: const Text(
                'Connect',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
