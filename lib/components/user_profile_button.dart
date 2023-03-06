import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/services/cached_image_manager.dart';
import 'package:fluxmobileapp/stores/user_profile_store.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:provider/provider.dart';

class UserProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProfileStore = Provider.of<UserProfileStore>(
      context,
      listen: false,
    );
    return IconButton(
      icon: Container(
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   border: Border.all(
        //     color: context.isLight
        //         ? const Color(0xffF3F8FF)
        //         : Theme.of(context).accentColor,
        //   ),
        // ),
        // padding: const EdgeInsets.all(2.5),
        child: Observer(
          builder: (BuildContext context) {
            return WidgetSelector(
              selectedState: userProfileStore.getProfileState,
              states: {
                [DataState.loading]: const SizedBox(
                  height: 16,
                  width: 16,
                  child: const Center(
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                [DataState.error]: Center(
                  child: ErrorDataWidget(
                    text: userProfileStore.getProfileState.message ?? '',
                  ),
                ),
                [DataState.success]: Observer(
                  builder: (BuildContext context) {
                    return CachedNetworkImage(
                      imageUrl: userProfileStore.userProfile!.avatar ?? '',
                      cacheManager: NoCachedImageManager(),
                      placeholder: (context, url) => const SizedBox(
                        height: 16,
                        width: 16,
                        child: const Center(
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xffF3F8FF),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => ProfilePicture(
                        name: '${userProfileStore.userProfile?.fullname}',
                        radius: 40.0,
                        fontsize: 11,
                      ),
                      // const Icon(
                      //   Icons.account_circle,
                      //   color: const Color(0xffF3F8FF),
                      // ),
                    );
                  },
                ),
              },
            );
          },
        ),
      ),
      iconSize: 35.0,
      onPressed: () {
        userProfileStore.goToSettings.executeIf();
      },
    );
  }
}
