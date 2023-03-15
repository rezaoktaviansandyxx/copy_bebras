import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/rating_widget.dart';
import 'package:fluxmobileapp/widgets/session_item_widget.dart';
import 'package:get/get.dart';

class DetailArticleStaticScreen extends StatefulWidget {
  const DetailArticleStaticScreen({Key? key}) : super(key: key);

  @override
  State<DetailArticleStaticScreen> createState() =>
      _DetailArticleStaticScreenState();
}

class _DetailArticleStaticScreenState extends State<DetailArticleStaticScreen> {
  final double listHeight = 250;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 60 / 100,
                ),
                // AppClipPath(
                //   height: 150,
                // ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 28 / 100,
                  width: MediaQuery.of(context).size.width,
                  child: ClipPath(
                    child: Image.asset(
                      'images/bebras/Itera-2017-01-300x225 2.png',
                      fit: BoxFit.cover,
                    ),
                    clipper: CurveClipper(),
                  ),
                ),
                // CustomPaint(
                //   child: Container(
                //     height: 150,
                //     decoration: BoxDecoration(
                //       image: DecorationImage(
                //         image: NetworkImage(
                //           'images/bebras/Itera-2017-01-300x225 2.png',
                //         ),
                //       ),
                //     ),
                //   ),
                //   painter: CurveWidget(
                //     color: Color(0XFF00ADEE).withOpacity(0.25),
                //   ),
                // ),
                // Image.asset('images/bebras/Itera-2017-01-300x225 2.png'),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 30 / 100,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Institut Teknologi Sumatera, Bandar Lampung 23 September 2017',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'by: Admin',
                          ),
                          RatingWidget(
                            rating: 5,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '‘ Workshop Computational Thinking Initiative’ Ketua NBO Bebras Indonesia, Dr. Inggriani',
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 22 / 100,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Berita Lainnya',
                          style: AppTheme.of(context).sectionTitle,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: listHeight,
                        child: ListView.builder(
                          itemCount: 1,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: AspectRatio(
                                    aspectRatio: listHeight / (listHeight + 90),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        10,
                                      ),
                                      child: SessionItemWidget(
                                        useExpandedCategory: false,
                                        item: SessionItem()
                                          ..title =
                                              'Univesitas Lambung \nMangkurat, Samarinda \n18 Juli 2017'
                                          ..category = 'Artikel'
                                          ..imageThumbnail =
                                              'images/bebras/Unlam-2017-01-270x270 1.png'
                                              ..author = 'Bebras Indonesia',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: AspectRatio(
                                    aspectRatio: listHeight / (listHeight + 90),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        10,
                                      ),
                                      child: SessionItemWidget(
                                        useExpandedCategory: false,
                                        item: SessionItem()
                                          ..title =
                                              'Univesitas Lambung \nMangkurat, Samarinda \n18 Juli 2017'
                                          ..category = 'Artikel'
                                          ..imageThumbnail =
                                              'images/bebras/Unlam-2017-01-270x270 1.png'
                                          ..author = 'Bebras Indonesia',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     // AspectRatio(
                      //     //   aspectRatio: listHeight / (listHeight + 100),
                      //     //   child: SessionItemWidget(
                      //     //     item: SessionItem()
                      //     //       ..imageThumbnail =
                      //     //           'images/bebras/Unlam-2017-01-270x270 1.png'
                      //     //       ..category = 'Artikel'
                      //     //       ..title =
                      //     //           'Univesitas Lambung \nMangkurat, Samarinda \n18 Juli 2017',
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
