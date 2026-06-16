class AiConfig {
  static const String ngrokDomain = "roundup-camera-unsteady.ngrok-free.dev";
  static const String restBaseUrl = "https://$ngrokDomain";
  static const String wsBaseUrl = "wss://$ngrokDomain";
  
  // NOTE: Keep this secure! Do not commit hardcoded keys to public repos.
  static const String apiKey = "zqMjzbY59LGYgCYUwI03d5cHgsade62pYw8WemyTxJM";
}
