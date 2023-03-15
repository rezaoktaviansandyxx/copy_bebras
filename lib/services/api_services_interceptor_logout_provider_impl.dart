import 'package:fluxmobileapp/api_services/api_services_interceptor.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/stores/user_profile_store.dart';

import '../appsettings.dart';

class ApiServicesInterceptorLogoutProviderImpl
    implements ApiServicesInterceptorLogoutProvider {
  final appServices = sl.get<AppServices>();

  var isTryingToLogout = false;

  @override
  Future logout() async {
    try {
      if (isTryingToLogout == true) {
        return;
      }

      isTryingToLogout = true;

      final routeName = latestRoute;
      if (routeName == '/login') {
        return;
      }

      final userProfileStore = sl.get<UserProfileStore>()!;
      await userProfileStore.logout.executeIf();
    } catch (error) {
      logger.e(error);
    } finally {
      isTryingToLogout = false;
    }
  }
}
