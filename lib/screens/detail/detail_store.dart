import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/todo_detail/todo_detail_screen.dart';
import 'package:fluxmobileapp/screens/todo_detail/todo_detail_store.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';

import '../../appsettings.dart';
import '../../api_services/api_services.dart';

part 'detail_store.g.dart';

class DetailStore = _DetailStore with _$DetailStore;

abstract class _DetailStore extends BaseStore with Store {
  _DetailStore({
    AppServices? appServices,
    AppClientServices? appClientServices,
    Map<String, Object>? parameters,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClientServices = appClientServices ?? sl.get<AppClientServices>();

    goToCorrespondingDetail = Command(() async {
      try {
        state = DataState.loading;

        void pushToDetail(
          BrowseType? typeEnum,
          String? id, {
          Object? additionalData,
        }) {
          if (typeEnum == BrowseType.article) {
            Get.offNamed('/detail_article', arguments: {
              'articleId': id,
            });
            // appServices!.navigatorState!.pushReplacementNamed(
            //   '/detail_article',
            //   arguments: {
            //     'articleId': id,
            //   },
            // );
            return;
          } else if (typeEnum == BrowseType.podcast) {
            Get.offNamed('/detail_podcast', arguments: {
              'podcastId': id,
              'episodeId': additionalData,
            });
            // appServices!.navigatorState!.pushReplacementNamed(
            //   '/detail_podcast',
            //   arguments: {
            //     'podcastId': id,
            //     'episodeId': additionalData,
            //   },
            // );
            return;
          } else if (typeEnum == BrowseType.video) {
            Get.offNamed('/detail_video', arguments: {
              'videoId': id,
            });
            // appServices!.navigatorState!.pushReplacementNamed(
            //   '/detail_video',
            //   arguments: {
            //     'videoId': id,
            //   },
            // );
            return;
          } else if (typeEnum == BrowseType.series) {
            Get.offNamed('/detail_session', arguments: {
              'sessionId': id,
            });
            // appServices!.navigatorState!.pushReplacementNamed(
            //   '/detail_session',
            //   arguments: {
            //     'sessionId': id,
            //   },
            // );
            return;
          }
        }

        final item = Get.arguments['item'];
        if (item is ArticleItem) {
          await appClientServices!.addActivity(
            AddUserActivityRequest()
              ..authorName = item.author
              ..contentId = item.id
              ..imageThumbnail = item.imageThumbnail
              ..isCompleted = false
              ..title = item.title
              ..type = getBrowseTypeName(BrowseType.article),
          );
          Get.offNamed('/detail_article', arguments: {
            'articleId': item.id,
          });
          // appServices!.navigatorState!.pushReplacementNamed(
          //   '/detail_article',
          //   arguments: {
          //     'articleId': item.id,
          //   },
          // );
        } else if (item is BrowseModel) {
          await appClientServices!.addActivity(
            AddUserActivityRequest()
              ..authorName = item.author
              ..contentId = item.id
              ..imageThumbnail = item.imageThumbnail
              ..isCompleted = false
              ..title = item.title
              ..type = item.type,
          );

          pushToDetail(item.typeEnum, item.id);
        } else if (item is SeriesEpisode) {
          await appClientServices!.addActivity(
            AddUserActivityRequest()
              ..authorName = item.author
              ..contentId = item.id
              ..imageThumbnail = item.imageThumbnail
              ..isCompleted = false
              ..title = item.title
              ..type = item.type,
          );

          pushToDetail(item.typeEnum, item.id);
        } else if (item is RecentSessionModel) {
          pushToDetail(item.typeEnum, item.contentId);
        } else if (item is NotificationModel) {
          logger.i('Notification detail ${item.toJson()}');

          late AddUserActivityRequest activityRequest;
          if (item.typeEnum == NotificationType.article) {
            final detail = (await appClientServices!.getDetailArticle(
              item.id,
            ))
                .payload!;
            activityRequest = AddUserActivityRequest()
              ..authorName = detail.author
              ..contentId = detail.id
              ..imageThumbnail = detail.imageThumbnail
              ..isCompleted = false
              ..title = detail.title
              ..type = item.type;
          } else if (item.typeEnum == NotificationType.podcast) {
            final _response = await appClientServices!.getDetailPodcast(
              item.id,
            );
            final detail = _response.payload!;
            activityRequest = AddUserActivityRequest()
              ..authorName = detail.author
              ..contentId = detail.id
              ..imageThumbnail = detail.imageThumbnail
              ..isCompleted = false
              ..title = detail.title
              ..type = item.type;
          } else if (item.typeEnum == NotificationType.series) {
            final _response = await appClientServices!.getDetailSeries(
              item.id,
            );
            final detail = _response.payload!;
            activityRequest = AddUserActivityRequest()
              ..authorName = detail.author
              ..contentId = detail.id
              ..imageThumbnail = detail.imageThumbnail
              ..isCompleted = false
              ..title = detail.title
              ..type = item.type;
          } else if (item.typeEnum == NotificationType.video) {
            final _response = await appClientServices!.getDetailVideo(
              item.id,
            );
            final detail = _response.payload!;
            activityRequest = AddUserActivityRequest()
              ..authorName = detail.author
              ..contentId = detail.id
              ..imageThumbnail = detail.imageThumbnail
              ..isCompleted = false
              ..title = detail.title
              ..type = item.type;
          } else if (item.typeEnum == NotificationType.reminder) {
            final _response = await appClientServices!.getTodo(
              item.id,
            );
            final response = _response.payload;
            appServices!.navigatorState!.pushReplacement(MaterialPageRoute(
              settings: RouteSettings(
                name: '/tododetail_detail_store',
              ),
              builder: (BuildContext context) {
                final store = TodoDetailStore(
                  context,
                );
                store.todoItem = response;
                return Observer(
                  builder: (BuildContext context) {
                    final detail = store.todoItem;

                    return TodoDetailScreen(
                      todoItem: store.todoItem,
                      state: store.editTodoState,
                      provider: TodoDetailProvider(
                        onMarkAsDone: () {
                          store.onMarkAsDone.executeIf(detail);
                        },
                        onDelete: () {
                          store.onDelete.executeIf(detail);
                        },
                        onSaved: (v) {
                          store.editTodo.executeIf(v);
                        },
                        // onDueDateChanged: (v) {
                        //   store.editDueDate.executeIf(Tuple2(detail, v));
                        // },
                        // onHourChanged: (v) {
                        //   store.editHour.executeIf(Tuple2(detail, v));
                        // },
                        // onNotesChanged: (v) {
                        //   store.editNotes.executeIf(Tuple2(detail, v));
                        // },
                        // onReminderDateChanged: (v) {
                        //   store.editReminder.executeIf(
                        //     Tuple3(detail, detail.reminderType, v),
                        //   );
                        // },
                        // onReminderTypeChanged: (v) {
                        //   if (v == ReminderTypeEnum.once) {
                        //     return;
                        //   }

                        //   store.editReminder.executeIf(
                        //     Tuple3(detail, v, detail.reminderDate),
                        //   );
                        // },
                        // onReminderChanged: (v1, v2) {
                        //   store.editReminder.executeIf(
                        //     Tuple3(
                        //       detail,
                        //       v1,
                        //       v2,
                        //     ),
                        //   );
                        // },
                      ),
                    );
                  },
                );
              },
            ));
            return;
          }

          await appClientServices!.addActivity(
            activityRequest,
          );
          pushToDetail(parseBrowseType(item.type), item.id);
        } else {
          throw ArgumentError(
            'Detail not implemented',
          );
        }
      } catch (error) {
        logger.e(error);

        state = DataState(
          enumSelector: EnumSelector.error,
          message: getErrorMessage(error),
        );
      }
    });
  }

  @observable
  var state = DataState.none;

  late Command goToCorrespondingDetail;
}
