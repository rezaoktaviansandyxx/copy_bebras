import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/interest/interest_picker_badge.dart';
import 'package:fluxmobileapp/stores/interest_store.dart';
import 'package:fluxmobileapp/stores/tutorial_walkthrough_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:tuple/tuple.dart';
import '../../screens/assessment/assessment_chart_store.dart';

class InterestPicker extends StatefulWidget {
  final Function? onSaved;
  final bool firstTime;
  InterestPicker({
    this.onSaved,
    this.firstTime = false,
    Key? key,
  }) : super(key: key);

  _InterestPickerState createState() => _InterestPickerState();
}

class _InterestPickerState extends State<InterestPicker>
    with SingleTickerProviderStateMixin {
  final appServices = sl.get<AppServices>();

  late TabController _tabController;
  final _tabStream = BehaviorSubject.seeded(0);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: 2,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _tabStream.add(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asssessmentChartStore = Provider.of<AssessmentChartStore>(
      context,
      listen: false,
    );
    asssessmentChartStore.dataRefresher.add(null);

    final interestStore = Provider.of<InterestStore>(
      context,
      listen: false,
    );
    interestStore.dataRefresher.add(null);

    final scaffold = Scaffold(
      backgroundColor: context.isLight ? Colors.transparent : null,
      appBar: AppBar(
        backgroundColor: context.isLight ? Colors.transparent : null,
        iconTheme: IconThemeData(
          color: context.isLight ? Colors.white : null,
        ),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back,
        //   ),
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        // ),
        title: Text(
          'Topic Interest',
          style: TextStyle(
            color: context.isLight ? Colors.white : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              bottom: 50,
            ),
            child: Container(
              child: Text(
                'Choose the topics below that interest you, you can choose more than 1 topic',
                style: AppTheme.of(context).listItemTitleSettings.copyWith(
                      fontSize: FontSizesWidget.of(context)!.thin,
                      color: context.isLight
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (BuildContext context) {
                return WidgetSelector(
                  selectedState: interestStore.state,
                  states: {
                    [DataState.success]: Observer(
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TopicListView(
                                  topics: interestStore.items.length > 0
                                      ? interestStore.items
                                      : [],
                                  onChangedItem: (v) {
                                    final newList =
                                        interestStore.items.map((f) {
                                      if (v.id == f.id) {
                                        return v;
                                      }

                                      return TopicItem.fromJson(f.toJson());
                                    }).toList();
                                    interestStore.changeItems((f) {
                                      f.clear();
                                      f.addAll(newList);
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  '${interestStore.items.where((t) => t.isSelected == true).length} topic selected as your interest',
                                  style: TextStyle(
                                    color: const Color(0xff5AD57F),
                                    fontSize: FontSizes.regular,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextButton(
                                  onPressed: () {
                                    interestStore.saveInterest.executeIf(Tuple2(
                                        widget.onSaved, widget.firstTime));
                                  },
                                  child: Text(
                                    'Save Interest Topic',
                                    style: TextStyle(
                                      color:
                                          context.isLight ? Colors.white : null,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 50,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    [DataState.loading]: Center(
                      child: CircularProgressIndicator(),
                    ),
                    [DataState.error]: ErrorDataWidget(
                      text: interestStore.state.message ?? '',
                      onReload: () {
                        interestStore.dataRefresher.add(null);
                      },
                    ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
    return Container(
      color: context.isLight ? const Color(0xffF3F8FF) : null,
      child: Stack(
        children: [
          AppClipPath(
            height: 170,
          ),
          scaffold,
        ],
      ),
    );
  }
}

class TopicListView extends StatelessWidget {
  final List<TopicItem> topics;
  final Function(TopicItem)? onChangedItem;
  final EdgeInsets padding;
  final TutorialWalkthroughStore? tutorialWalkthroughStore;

  const TopicListView({
    required this.topics,
    this.onChangedItem,
    this.padding = const EdgeInsets.all(0),
    Key? key,
    this.tutorialWalkthroughStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 15,
      ),
      itemCount: topics.length,
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final item = topics[index];

        return InterestPickerBadge(
          item: item,
          onChangedItem: (i) {
            onChangedItem!(i);
          },
        );
      },
    );

    return tutorialWalkthroughStore == null
        ? content
        : TutorialWalkthroughBasic(
            selectedTutorialIndex: 3,
            store: tutorialWalkthroughStore,
            child: content,
            tooltipDirection: TooltipDirection.up,
          );
  }
}
