import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/imagepath.dart';

import '../../appsettings.dart';
import 'home_carousel_store.dart';

class HomeCarouselScreen extends StatefulWidget {
  HomeCarouselScreen({Key? key}) : super(key: key);

  _HomeCarouselScreenState createState() => _HomeCarouselScreenState();
}

class _HomeCarouselScreenState extends State<HomeCarouselScreen>
    with BaseStateMixin<HomeCarouselStore, HomeCarouselScreen> {
  final localization = sl.get<ILocalizationService>();

  final _store = HomeCarouselStore();
  @override
  HomeCarouselStore get store => _store;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      child: Observer(
        builder: (BuildContext context) {
          return Swiper(
            itemCount: store.items.length,
            scale: 1,
            loop: false,
            itemBuilder: (BuildContext context, int index) {

              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: const Radius.circular(24),
                        topLeft: const Radius.circular(24),
                        topRight: const Radius.circular(24),
                      ),
                      child: Stack(
                        children: <Widget>[
                          LayoutBuilder(
                            builder: (context, c) {
                              return Image.network(
                                'https://images.unsplash.com/photo-1523719185231-aff40a400361?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80',
                                fit: BoxFit.cover,
                                width: c.biggest.width,
                              );
                            },
                          ),
                          Container(
                            color: Theme.of(context).canvasColor.withOpacity(
                                  0.7,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 40,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).accentColor,
                            ),
                            child: Text(
                              localization!.getByKey('home.card_new'),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                          ),
                          child: Text(
                            'fdkajf fjldsakjfdlsak jfdlskajfds flkfdkajf fjldsakjfdlsak jfdlskajfds flkfdkajf fjldsakjfdlsak jfdlskajfds flkfdkajf fjldsakjfdlsak jfdlskajfds flkfdkajf fjldsakjfdlsak jfdlskajfds flkfdkajf fjldsakjfdlsak jfdlskajfds flk',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: FontSizes.cardTitle,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 40,
                                ),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            '23.05.2019',
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Image.asset(
                                            getImagePath('images/Time.png'),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '23.05.2019,',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'fdkajf fjldsakjfdlsak jfdlskajfds flk',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
