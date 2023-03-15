import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:firebase_core/firebase_core.dart';

var idNotification = -1;

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final notificationsStream = BehaviorSubject<Map<String, dynamic>?>.seeded(null);
StreamSubscription? notificationsSubs;
notificationSubscribeSafe(Future Function(Map<String, dynamic>?) function) {
  if (notificationsSubs != null) {
    return;
  }

  notificationsSubs = notificationsStream
      .flatMap((v) => DeferStream(() {
            return function(v).asStream();
          }))
      .listen(null);
}

Future initLocalNotification() async {
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  var initializationSettingsIOS = DarwinInitializationSettings(
    onDidReceiveLocalNotification: (v1, v2, v3, v4) {
      logger.i('onDidReceiveLocalNotification: $v1, $v2, $v3, $v4');
      // return Future.value(null);
    },
  );
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (v) {
      logger.i('onDidReceiveNotificationResponse: $v');
      final map = Map<String, dynamic>.from(jsonDecode(v.payload!));
      notificationsStream.add(map);
      // return Future.value(null);
    },
  );
}

Future onBackgroundMessage(v) {
  logger.i('onBackgroundMessage: $v');
  return Future.value(null);
}

final fcmTokenRefresher = PublishSubject<String>();
FirebaseMessaging? _firebaseMessaging;

Future initFirebase() async {
  await Firebase.initializeApp();
  await initLocalNotification();

  _firebaseMessaging = FirebaseMessaging.instance;
  await _firebaseMessaging!.requestPermission();
  FirebaseMessaging.onMessage.asyncMap((v) async {
    idNotification++;
    final id = idNotification.toString();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      id,
      id,
      channelDescription: id,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'appmobile',
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    final payloadNotification = v.data['data'] ?? v.data;
    late Map<String, dynamic> dataMaps;
    if (Platform.isAndroid) {
      dataMaps = Map<String, dynamic>.from(
        v.data['notification'],
      );
    } else if (Platform.isIOS) {
      dataMaps = Map<String, dynamic>.from(
        v.data['aps']['alert'],
      );
    }
    await flutterLocalNotificationsPlugin.show(
      idNotification,
      dataMaps['title'],
      dataMaps['body'],
      platformChannelSpecifics,
      payload: jsonEncode(payloadNotification),
    );

    logger.i('onMessage: $v');
  }).listen(((e) => {}) as void Function(Null)?);

  FirebaseMessaging.onMessageOpenedApp.listen((v) {
    logger.i('onLaunch: $v');
    final map = Map<String, dynamic>.from(v.data['data'] ?? v as Map<dynamic, dynamic>);
    notificationsStream.add(map);
  });
  
  // FirebaseMessaging.onMessage.listen(
  //   onLaunch: (v) {},
  //   onResume: (v) {
  //     logger.i('onResume: $v');
  //     final map = Map<String, dynamic>.from(v['data'] ?? v);
  //     notificationsStream.add(map);
  //     return Future.value(null);
  //   },
  //   onBackgroundMessage: onBackgroundMessage,
  // );
  final appClient = sl.get<AppClientServices>();
  final secureStorage = sl.get<SecureStorage>();
  _firebaseMessaging!.onTokenRefresh
      .mergeWith([fcmTokenRefresher])
      .doOnData((v) {
        logger.i('FCM token: $v');
      })
      .flatMap((v) => DeferStream(() {
            return secureStorage!.getLoginResponse().asStream().map((user) {
              return Tuple2(v, user);
            });
          }))
      .where((v) {
        final isAuthenticated = v.item2 != null;
        logger.i('Update FCM denied, is user authenticated? $isAuthenticated');
        return isAuthenticated;
      })
      .asyncMap((v) {
        return appClient!.updateFcmToken(v.item1);
      })
      .handleError((error) {
        logger.e('Error update FCM token: $error');
      })
      .listen((v) {
        logger.i('FCM token updated to server: $v');
      });
}

FirebaseMessaging? get firebaseMessagingInstance => _firebaseMessaging;
