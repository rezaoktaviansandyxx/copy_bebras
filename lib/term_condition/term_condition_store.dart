import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:mobx/mobx.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';

part 'term_condition_store.g.dart';

class TermConditionStore = _TermConditionStore with _$TermConditionStore;

abstract class _TermConditionStore extends BaseStore with Store {
  _TermConditionStore({
    AppServices? appServices,
    AppClientServices? appClientServices,
  }) {
    appClientServices ??= sl.get<AppClientServices>();
    appServices ??= sl.get<AppServices>();

    getTermCondition = Command.parameter((p) async {
      try {
        getDataState = DataState.loading;

        if (p == TermConditionType.aboutus) {
          final _termCondition = await appClientServices!.getAboutUs();
          termCondition = _termCondition.payload!.first;
        } else if (p == TermConditionType.privacy) {
          final _termCondition = await appClientServices!.getPrivacyPolicy();
          termCondition = _termCondition.payload!.first;
        }

        getDataState = DataState.success;
      } catch (error) {
        getDataState = DataState(
          enumSelector: EnumSelector.error,
          message: error.toString(),
        );
      }
    });
  }

  @observable
  var getDataState = DataState.none;

  late Command<TermConditionType> getTermCondition;

  @observable
  TermConditionModel? termCondition;
}
