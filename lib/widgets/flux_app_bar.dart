import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';

class FluxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Size? preferredSizeAppBar;
  const FluxAppBar({
    Key? key,
    this.actions,
    this.preferredSizeAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      elevation: 0,
      backgroundColor: context.isLight ? Colors.transparent : null,
      title: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'images/logo_bebras.svg',
              height: kToolbarHeight - 15,
            ),
            // const SizedBox(
            //   width: 5,
            // ),
            // Text(
            //   'Anugra',
            //   style: TextStyle(
            //     fontFamily: 'Quicksand',
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //     fontSize: 24,
            //   ),
            // ),
          ],
        ),
      ),
      actions: actions,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize =>
      preferredSizeAppBar ??
      Size.fromHeight(
        kToolbarHeight,
      );
}
