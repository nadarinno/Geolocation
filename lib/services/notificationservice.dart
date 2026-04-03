
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
   
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    
    await FirebaseMessaging.instance.subscribeToTopic("stores");

  
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

   
  }
}