class SafeZone {
  String name;
  int radius;
  bool active;
  bool sendNotifications;

  SafeZone({
    required this.name,
    required this.radius,
    this.active = true,
    this.sendNotifications = false,
  });
}
