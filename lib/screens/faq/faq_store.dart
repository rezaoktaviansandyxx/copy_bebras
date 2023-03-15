import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/disposable.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:quiver/strings.dart';

part 'faq_store.g.dart';

class FaqFilterModel {
  String? searchKeyword;
}

class FaqStore = _FaqStore with _$FaqStore;

abstract class _FaqStore extends BaseStore with Store {
  _FaqStore({
    AppServices? appServices,
    AppClientServices? appClientServices,
  }) {
    appClientServices ??= sl.get<AppClientServices>();
    appServices ??= sl.get<AppServices>();

    _getFaqs = Command.parameter((p) async {
      try {
        faqsState = DataState.loading;

        final _faqs = await appClientServices!.getFaqs();

        final _filteredFaqs = isBlank(p?.searchKeyword)
            ? _faqs.payload!
            : _faqs.payload!.where((element) => element.question!
                    .toLowerCase()
                    .contains(p?.searchKeyword ?? '')) ??
                [];
        faqs.clear();
        if (_filteredFaqs.isEmpty) {
          faqsState = DataState.empty;
        } else {
          faqs.addAll(_filteredFaqs);
          faqsState = DataState.success;
        }
      } catch (error) {
        faqsState = DataState(
          enumSelector: EnumSelector.error,
          message: error.toString(),
        );
      }
    });

    getDetailFaq = Command.parameter((parameter) async {
      try {
        final _detailFaq = faqs[parameter!];
        detailFaq = _detailFaq;
      } catch (error) {
        logger.e(error);
      }
    });

    final d = _faqFilter.where((event) => event != null).asyncMap((e) {
      return _getFaqs.executeIf(e);
    }).listen(null);
    disposables.add(DisposableBuilder(disposeFunction: () {
      d.cancel();
    }));
  }

  @observable
  var faqsState = DataState.none;

  late Command<FaqFilterModel> _getFaqs;

  // ignore: close_sinks
  final _faqFilter = BehaviorSubject<FaqFilterModel>.seeded(FaqFilterModel());
  FaqFilterModel get faqFilter {
    return _faqFilter.value;
  }

  set faqFilter(FaqFilterModel value) {
    _faqFilter.add(value);
  }

  final faqs = ObservableList<FaqModel>();

  @observable
  var detailFaqState = DataState.none;

  late Command<int> getDetailFaq;

  final _detailFaq = Observable<FaqModel?>(null);
  FaqModel? get detailFaq {
    return _detailFaq.value;
  }

  set detailFaq(FaqModel? value) {
    _detailFaq.value = value;
  }
}
