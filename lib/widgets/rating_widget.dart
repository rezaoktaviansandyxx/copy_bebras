import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluxmobileapp/utils/utils.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  const RatingWidget({
    Key? key,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _rating = !rating.isNaN ? rating : 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            right: 5,
          ),
          child: RatingBarIndicator(
            rating: _rating,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 20,
          ),
        ),
        Text(
          '(${removeDecimalZeroFormat(_rating)})',
          style: TextStyle(
            fontSize: 15,
            color: rating >= 1
                ? const Color(0xffECC23B)
                : Theme.of(context).iconTheme.color,
          ),
        ),
      ],
    );
  }
}
