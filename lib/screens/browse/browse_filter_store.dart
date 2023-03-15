import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

import '../../api_services/api_services_models.dart';
import '../../api_services/api_services.dart';
import '../../appsettings.dart';

part 'browse_filter_store.g.dart';

class BrowseFilterStore = _BrowseFilterStore with _$BrowseFilterStore;

abstract class _BrowseFilterStore extends BaseStore with Store {
  _BrowseFilterStore({
    AppServices? appServices,
    AppClientServices? appClientServices,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClientServices = appClientServices ?? sl.get<AppClientServices>();

    const int pageSize = 999999999;

    getDefaultFilter = Command.parameter((p) async {
      final param = p ?? {};
      final TopicItem? paramTopicItem = param['topicItem'] as TopicItem?;
      // final authors = await appClientServices!.getListAuthor(
      //   page: 1,
      //   pageSize: pageSize,
      // );
      // final topics = await appClientServices.getTopic(
      //   GetTopicRequest()
      //     ..page = 1
      //     ..pageLimit = pageSize,
      // );
      BrowseFilterData createFilterData() {
        return BrowseFilterData(
          authors: [
            BrowseChipItem()
              ..id = 'Bebras Indonesia'
              ..name = 'Bebras Indonesia'
              ..isSelected = false,
          ],
          topics: [
            BrowseChipItem()
              ..id = 'Sikecil'
              ..name = 'Sikecil'
              ..isSelected = paramTopicItem?.name == 'Sikecil',
            BrowseChipItem()
              ..id = 'Siaga'
              ..name = 'Siaga'
              ..isSelected = paramTopicItem?.name == 'Siaga',
            BrowseChipItem()
              ..id = 'Penggalang'
              ..name = 'Penggalang'
              ..isSelected = paramTopicItem?.name == 'Penggalang',
            BrowseChipItem()
              ..id = 'Penegak'
              ..name = 'Penegak'
              ..isSelected = paramTopicItem?.name == 'Penegak',
          ],
          types: [
            BrowseChipItem()
              ..id = 'article'
              ..name = 'Artikel',
            BrowseChipItem()
              ..id = 'video'
              ..name = 'Materi Pembelajaran',
            BrowseChipItem()
              ..id = 'podcast'
              ..name = 'Latihan',
            BrowseChipItem()
              ..id = 'series'
              ..name = 'Contoh Soal',
          ],
        );
      }
          // authors.payload!.map((f) {
          //   return BrowseChipItem()
          //     ..id = f.name
          //     ..name = f.name;
          // }).toList(),
          // topics.payload!.map((f) {
          //   return BrowseChipItem()
          //     ..id = f.name
          //     ..name = f.name
          //     ..isSelected = paramTopicItem?.name == f.name;
          // }).toList(),

      if (filterData == null) {
        filterData = createFilterData();
      }
      filterDataSubject.add(
        createFilterData(),
      );
    });

    apply = Command(() async {
      // appServices!.navigatorState!.pop();
      Get.back();
      filterData = BrowseFilterData.fromMap(filterDataSubject.value.toMap());
    });

    registerDispose(() {
      filterDataSubject.close();
    });
  }

  @observable
  BrowseFilterData? filterData;

  final filterDataSubject = BehaviorSubject<BrowseFilterData>();

  late Command<Map<String, Object>> getDefaultFilter;

  late Command apply;

  @computed
  bool get containsFilter {
    // Haven't implemented this yet
    return false;
  }
}

class BrowseChipItem {
  String? id;
  String? name;
  bool? isSelected;

  Object? originalData;

  BrowseChipItem({
    this.id,
    this.name,
    this.isSelected,
    this.originalData,
  });

  factory BrowseChipItem.fromMap(Map<String, dynamic> json) => BrowseChipItem(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        isSelected: json["isSelected"] == null ? null : json["isSelected"],
        originalData: json["originalData"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "isSelected": isSelected == null ? null : isSelected,
        "originalData": originalData,
      };
}

class BrowseFilterData {
  final List<BrowseChipItem>? topics;

  final List<BrowseChipItem>? types;

  final int? rating;

  final List<BrowseChipItem>? authors;

  BrowseFilterData({
    this.topics,
    this.types,
    this.rating,
    this.authors,
  });

  factory BrowseFilterData.fromMap(Map<String, dynamic> json) =>
      BrowseFilterData(
        rating: json["rating"] == null ? null : json["rating"],
        topics: json["topics"] == null
            ? null
            : List<BrowseChipItem>.from(
                json["topics"].map((x) => BrowseChipItem.fromMap(x))),
        types: json["types"] == null
            ? null
            : List<BrowseChipItem>.from(
                json["types"].map((x) => BrowseChipItem.fromMap(x))),
        authors: json["authors"] == null
            ? null
            : List<BrowseChipItem>.from(
                json["authors"].map((x) => BrowseChipItem.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "rating": rating == null ? null : rating,
        "topics": topics == null
            ? null
            : List<dynamic>.from(topics!.map((x) => x.toMap())),
        "types": types == null
            ? null
            : List<dynamic>.from(types!.map((x) => x.toMap())),
        "authors": authors == null
            ? null
            : List<dynamic>.from(authors!.map((x) => x.toMap())),
      };
}
