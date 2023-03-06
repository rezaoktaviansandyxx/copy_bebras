import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/base_widgetparameter_mixin.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/detail/detail_store.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';

class DetailScreen extends StatefulWidget with BaseWidgetParameterMixin {
  DetailScreen({Key? key}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with BaseStateMixin<DetailStore?, DetailScreen> {
  DetailStore? _store;
  @override
  DetailStore? get store => _store;

  @override
  void initState() {
    super.initState();

    _store = DetailStore(
      parameters: widget.parameter,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store!.goToCorrespondingDetail.executeIf();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (BuildContext context) {
          return WidgetSelector(
            selectedState: store!.state,
            states: {
              [DataState.error]: Container(
                child: Center(
                  child: ErrorDataWidget(
                    text: store!.state.message,
                    onReload: () {
                      store!.goToCorrespondingDetail.executeIf();
                    },
                  ),
                ),
              ),
              [DataState.loading]: Center(
                child: CircularProgressIndicator(),
              ),
            },
          );
        },
      ),
    );
  }
}
