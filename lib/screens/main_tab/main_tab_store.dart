import 'dart:async';

import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/services/firebase_service.dart';
import 'package:rxdart/rxdart.dart';

class MainTabStore extends BaseStore {
  MainTabStore() {
    {
      notificationSubscribeSafe((v) {
        try {
          final map = v != null ? Map<String, dynamic>.from(v) : null;
          if (map == null || map.isEmpty == true) {
            return Future.value(null);
          }

          final appServices = sl.get<AppServices>();
          final model = NotificationModel.fromJson(v!);
          if (appServices?.navigatorState == null) {
            logger.i('navigatostate is null');
            return Future.value(null);
          }

          appServices!.navigatorState!.pushNamed('/detail', arguments: {
            'item': model,
          });
          return Future.value(null);
        } catch (error) {
          return Future.value(null);
        }
      });
    }

    registerDispose(() {
      tabIndex.close();
      topicStream.close();
      focusBrowseSearch.close();
    });
  }

  final tabIndex = BehaviorSubject.seeded(0);

  final topicStream = BehaviorSubject<TopicItem?>.seeded(null);

  var focusBrowseSearch = BehaviorSubject<bool>.seeded(false);
}
