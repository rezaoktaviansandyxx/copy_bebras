import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:quiver/strings.dart';

part 'find_url_company_store.g.dart';

class FindUrlCompanyStore = _FindUrlCompanyStore with _$FindUrlCompanyStore;

abstract class _FindUrlCompanyStore extends BaseStore with Store {
  _FindUrlCompanyStore({
    AppClientServices? appClientServices,
  }) {
    appClientServices ??= sl.get<AppClientServices>();

    sendUrlCompany = Command(() async {
      if (isBlank(email)) {
        return;
      }

      try {
        state = DataState.loading;

        final result = await appClientServices!.findCompany(email!.trim());
        if (result.payload == null) {
          throw "Couldn't sent URL company name";
        } else {
          alertInteraction.handle(
            'Your company name is "${result.payload!.companyName}"',
          );
        }
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(getErrorMessage(error));
      } finally {
        state = DataState.none;
      }
    });
  }

  String? email;

  late Command sendUrlCompany;

  final alertInteraction = Interaction<String?, bool?>();

  @observable
  var state = DataState.none;
}
