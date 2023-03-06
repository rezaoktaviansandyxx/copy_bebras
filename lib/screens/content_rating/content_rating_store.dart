import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';

class ContentRatingStore {
  ContentRatingStore({
    AppClientServices? appClientServices,
  }) {
    appClientServices ??= sl.get<AppClientServices>();

    rateContent = Command.parameter((p) async {
      try {
        await appClientServices!.contentRate(p!);

        rating.value = p.rating ?? 0;
      } catch (error) {
        alertInteraction.handle(getErrorMessage(error));

        dataState = DataState(
          enumSelector: EnumSelector.error,
          message: error.toString(),
        );
        throw error;
      }
    });
  }

  late Command<RateContentRequest> rateContent;

  DataState? dataState;

  final alertInteraction = Interaction<String?, bool?>();

  final rating = Observable(0);
}
