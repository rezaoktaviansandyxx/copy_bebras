import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'api_services_models.g.dart';

@JsonSerializable()
class RegisterUserRequest {
  String? id;
  String? username;
  String? password;
  String? fullname;
  String? email;
  String? birthPlace;
  DateTime? birthDay;
  String? avatar;
  int? userType;

  RegisterUserRequest({
    this.id,
    this.username,
    this.password,
    this.fullname,
    this.email,
    this.birthPlace,
    this.birthDay,
    this.avatar,
    this.userType,
  });

  factory RegisterUserRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterUserRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  String? username;
  String? password;
  String? companySite;

  LoginRequest();

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  String? token;
  String? tokenScheme;
  bool? isFirstLogin;

  /// This property is coming from client not server
  bool? isFirstLoginAndEmptyAssessment;

  LoginResponse();

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class BaseResponse<T> {
  BaseResponse();

  int? statusCode;

  String? message;

  @JsonKey(ignore: true)
  T? payload;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) map,
  ) {
    final tempResponse = _$BaseResponseFromJson(json);
    final response = BaseResponse<T>()
      ..message = tempResponse.message
      ..statusCode = tempResponse.statusCode;
    response.payload = map(json['payload']);
    return response;
  }
}

@JsonSerializable()
class UserProfile {
  String? userId;
  String? username;
  String? fullname;
  late DateTime? createdDate;
  String? type;
  int? userType;
  String? email;
  String? birthPlace;
  late DateTime? birthDay;
  String? avatar;
  String? registerProvider;
  int? assessmentVersion;

  UserProfile();

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class GetTopicRequest {
  @JsonKey(name: 'p')
  int? page;

  @JsonKey(name: 's')
  int? pageLimit;

  @JsonKey(name: 'q')
  String? query;

  GetTopicRequest();

  factory GetTopicRequest.fromJson(Map<String, dynamic> json) =>
      _$GetTopicRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetTopicRequestToJson(this);
}

@JsonSerializable()
class GetRecentSessionRequest {
  @JsonKey(name: 'Id')
  String? id;

  @JsonKey(name: 'IsCompleted')
  bool? isCompleted;

  @JsonKey(name: 'p')
  int? page;

  @JsonKey(name: 's')
  int? pageLimit;

  @JsonKey(name: 'q')
  String? query;

  GetRecentSessionRequest();

  factory GetRecentSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$GetRecentSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetRecentSessionRequestToJson(this);
}

@JsonSerializable()
class TopicItem {
  String? id;
  String? name;
  String? description;
  late DateTime? createdDt;
  late DateTime? updatedDt;
  String? color;
  String? iconUrl;

  bool? isSelected = false;

  TopicItem();

  factory TopicItem.fromJson(Map<String, dynamic> json) =>
      _$TopicItemFromJson(json);

  static List<TopicItem> fromListJson(List listJson) {
    return listJson.map((t) => _$TopicItemFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$TopicItemToJson(this);
}

@JsonSerializable()
class RecentSessionModel {
  String? id;
  String? userId;
  String? imageThumbnail;
  String? title;
  String? authorName;
  String? type;
  String? contentId;
  String? isCompleted;
  late DateTime? lastAccessDt;

  BrowseType? get typeEnum => parseBrowseType(type);

  RecentSessionModel();

  factory RecentSessionModel.fromJson(Map<String, dynamic> json) =>
      _$RecentSessionModelFromJson(json);

  static List<RecentSessionModel> fromListJson(List listJson) {
    return listJson.map((t) => _$RecentSessionModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$RecentSessionModelToJson(this);
}

@JsonSerializable()
class ArticleItem {
  String? id;
  String? title;
  String? description;
  String? tags;
  List<String>? listTag;
  String? author;
  String? publisherId;
  String? imageThumbnail;
  String? publisher;
  int? totalView;
  int? totalBookmark;
  int? rating;
  late DateTime? createdDt;
  late DateTime? updatedDt;

  ArticleItem();

  factory ArticleItem.fromJson(Map<String, dynamic> json) =>
      _$ArticleItemFromJson(json);

  static List<ArticleItem> fromListJson(List listJson) {
    return listJson.map((t) => _$ArticleItemFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$ArticleItemToJson(this);
}

@JsonSerializable()
class GetArticleRequest {
  @JsonKey(name: 'p')
  int? page;

  @JsonKey(name: 's')
  int? pageLimit;

  @JsonKey(name: 'q')
  String? query;

  GetArticleRequest();

  factory GetArticleRequest.fromJson(Map<String, dynamic> json) =>
      _$GetArticleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetArticleRequestToJson(this);
}

@JsonSerializable()
class AuthorModel {
  String? id;
  String? name;
  String? email;
  String? avatar;
  int? following;
  int? follower;
  int? totalVideos;
  int? totalPodcasts;
  int? totalArticles;
  int? totalSeries;

  AuthorModel();

  factory AuthorModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorModelFromJson(json);

  static List<AuthorModel> fromListJson(List listJson) {
    return listJson.map((t) => _$AuthorModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$AuthorModelToJson(this);
}

@JsonSerializable()
class GetActivityRequest {
  GetActivityRequest();

  @JsonKey(name: 'p')
  int? page;

  @JsonKey(name: 's')
  int? size;

  Map<String, dynamic> toJson() => _$GetActivityRequestToJson(this);
}

@JsonSerializable()
class ActivityItem {
  String? id;
  String? image;
  String? typeName;
  String? category;
  String? name;

  ActivityItem();

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);

  static List<ActivityItem> fromListJson(List listJson) {
    return listJson.map((t) => _$ActivityItemFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$ActivityItemToJson(this);
}

@JsonSerializable()
class GetAgendaRequest {
  GetAgendaRequest();

  late DateTime? date;

  Map<String, dynamic> toJson() => _$GetAgendaRequestToJson(this);
}

@JsonSerializable()
class ArticleDetailItem {
  ArticleDetailItem();

  String? id;
  String? title;
  String? description;
  String? tags;
  List<String>? listTag;
  String? author;
  String? htmlContent;
  late DateTime? publishDate;
  late DateTime? startDate;
  late DateTime? endDate;
  String? originalSource;
  String? imageThumbnail;
  String? imageUrl;
  String? publisherId;
  String? publisher;
  String? topics;
  int? totalView;
  int? totalBookmark;
  int? rating;
  late DateTime? createdDt;
  late DateTime? updatedDt;
  bool? isPublish;
  String? todoList;
  List<String>? todoListArr;
  int? totalUserRate;
  bool? userRated;

  factory ArticleDetailItem.fromJson(Map<String, dynamic> json) =>
      _$ArticleDetailItemFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleDetailItemToJson(this);
}

@JsonSerializable()
class GetBrowseRequest {
  @JsonKey(name: 'Topic')
  List<String?>? topic;

  @JsonKey(name: 'ContentType')
  List<String?>? contentType;

  @JsonKey(name: 'Rating')
  int? rating;

  @JsonKey(name: 'Author')
  List<String?>? author;

  @JsonKey(name: 'p')
  int? page;

  @JsonKey(name: 's')
  int? pageLimit;

  @JsonKey(name: 'q')
  String? query;

  GetBrowseRequest();

  Map<String, dynamic> toJson() => _$GetBrowseRequestToJson(this);
}

enum BrowseType {
  article,
  video,
  series,
  podcast,
}

BrowseType? parseBrowseType(String? type) {
  BrowseType? _typeEnum;
  if (type == 'article') {
    _typeEnum = BrowseType.article;
  } else if (type == 'podcast') {
    _typeEnum = BrowseType.podcast;
  } else if (type == 'video') {
    _typeEnum = BrowseType.video;
  } else if (type == 'series') {
    _typeEnum = BrowseType.series;
  } else {
    _typeEnum = BrowseType.values.firstWhereOrNull(
      (element) => element.toString() == type,
    );
  }

  return _typeEnum;
}

String getBrowseTypeName(BrowseType? type) {
  final name = type.toString().split('.')[1];
  return name;
}

@JsonSerializable()
class BrowseModel {
  String? id;
  String? title;
  String? description;
  String? type;
  String? imageThumbnail;
  int? rating;
  int? totalUserRate;
  double? rate;
  int? totalView;
  String? tags;
  List<String>? topics;
  String? author;

  BrowseType? get typeEnum => parseBrowseType(type);

  BrowseModel();

  factory BrowseModel.fromJson(Map<String, dynamic> json) =>
      _$BrowseModelFromJson(json);

  static List<BrowseModel> fromListJson(List listJson) {
    return listJson.map((t) => _$BrowseModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$BrowseModelToJson(this);
}

@JsonSerializable()
class PodcastDetailItem {
  List<dynamic>? episodesInput;
  String? id;
  String? title;
  String? description;
  String? tags;
  List<String>? listTag;
  String? author;
  late DateTime? publishDate;
  String? originalSource;
  String? href;
  String? extPodcastId;
  String? mediaType;
  String? episodesContent;
  String? imageThumbnail;
  String? publisherId;
  String? publisher;
  int? totalView;
  int? totalBookmark;
  int? rating;
  late DateTime? createdDt;
  late DateTime? updatedDt;
  bool? isPublish;
  String? todoList;
  List<String>? todoListArr;
  List<PodcastEpisode>? episodes;
  int? totalUserRate;
  bool? userRated;

  PodcastDetailItem();

  factory PodcastDetailItem.fromJson(Map<String, dynamic> json) =>
      _$PodcastDetailItemFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastDetailItemToJson(this);
}

@JsonSerializable()
class PodcastEpisode {
  String? audioPreviewUrl;
  String? description;
  int? durationMs;
  bool? explicit;
  Object? externalUrls;
  String? href;
  String? id;
  List<dynamic>? images;
  bool? isExternallyHosted;
  bool? isPlayable;
  String? language;
  List<String>? languages;
  String? name;
  late DateTime? releaseDate;
  String? releaseDatePrecision;
  Object? resumePoint;
  String? type;
  String? uri;

  PodcastEpisode();

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) =>
      _$PodcastEpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastEpisodeToJson(this);
}

@JsonSerializable()
class VideoDetailItem {
  String? id;
  String? title;
  String? description;
  String? tags;
  List<String>? listTag;
  String? author;
  late DateTime? publishDate;
  String? imageThumbnail;
  String? url;
  String? externalVideoId;
  int? channel;
  String? publisherId;
  String? publisher;
  int? totalView;
  int? totalBookmark;
  int? rating;
  int? totalUserRate;
  late DateTime? createdDt;
  late DateTime? updatedDt;
  bool? isPublish;
  String? todoList;
  List<String>? todoListArr;
  bool? userRated;

  VideoDetailItem();

  factory VideoDetailItem.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailItemFromJson(json);

  Map<String, dynamic> toJson() => _$VideoDetailItemToJson(this);
}

// Series models
@JsonSerializable()
class SeriesDetailItem {
  String? id;
  String? title;
  String? description;
  String? tags;
  List<String>? listTag;
  String? author;
  String? topics;
  String? imageThumbnail;
  late DateTime? publishDate;
  bool? isPublish;
  String? todoList;
  List<String>? todoListArr;
  String? todoListInput;
  String? publisher;
  int? totalView;
  int? totalBookmark;
  int? rating;
  late DateTime? createdDt;
  late DateTime? updatedDt;
  int? totalVideo;
  int? totalPodcast;
  int? totalArticle;
  List<SeriesEpisode>? items;
  int? totalUserRate;
  bool? userRated;

  SeriesDetailItem();

  factory SeriesDetailItem.fromJson(Map<String, dynamic> json) =>
      _$SeriesDetailItemFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesDetailItemToJson(this);
}

@JsonSerializable()
class SeriesEpisode {
  String? id;
  String? title;
  String? type;
  String? imageThumbnail;
  int? rating;
  String? author;

  BrowseType? get typeEnum => parseBrowseType(type);

  SeriesEpisode();

  factory SeriesEpisode.fromJson(Map<String, dynamic> json) =>
      _$SeriesEpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesEpisodeToJson(this);
}

@JsonSerializable()
class TodoItem extends _TodoItem with _$TodoItem {
  TodoItem();

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);

  static List<TodoItem> fromListJson(List listJson) {
    return listJson.map((t) => _$TodoItemFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$TodoItemToJson(this);

  void changeItem(TodoItem item) {
    dueDate = item.dueDate;
    id = item.id;
    isCompleted = item.isCompleted;
    isRecurring = item.isRecurring;
    name = item.name;
    notes = item.notes;
    reminderDate = item.reminderDate;
    reminderType = item.reminderType;
    hour = item.hour;
    goalName = item.goalName;
  }
}

abstract class _TodoItem with Store {
  @observable
  String? id;

  @observable
  String? goalName;

  @observable
  String? name;

  @observable
  DateTime? dueDate;

  @observable
  bool? isRecurring;

  @observable
  bool? isCompleted;

  @observable
  String? notes;

  @observable
  DateTime? reminderDate;

  @observable
  @ReminderTypeEnumConverter()
  ReminderTypeEnum? reminderType;

  @observable
  int? hour = 0;

  @computed
  bool get isValidReminder {
    if (reminderType == ReminderTypeEnum.once && reminderDate == null) {
      return false;
    } else {
      return true;
    }
  }

  _TodoItem();
}

enum ReminderTypeEnum {
  none,
  once,
  daily,
  weekly,
  montly,
}

class ReminderTypeEnumConverter
    implements JsonConverter<ReminderTypeEnum, Object> {
  const ReminderTypeEnumConverter();
  @override
  ReminderTypeEnum fromJson(Object json) {
    final r = ReminderTypeEnum.values[json as int];
    return r;
  }

  @override
  Object toJson(ReminderTypeEnum object) {
    return object.index;
  }
}

@JsonSerializable()
class GoalItem {
  String? id;
  String? name;
  String? userId;
  String? notes;

  @ListToObservable()
  ObservableList<TodoItem>? todos;

  GoalItem();

  factory GoalItem.fromJson(Map<String, dynamic> json) =>
      _$GoalItemFromJson(json);

  static List<GoalItem> fromListJson(List listJson) {
    return listJson.map((t) => _$GoalItemFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$GoalItemToJson(this);
}

class ListToObservable
    implements JsonConverter<ObservableList<TodoItem>, Object?> {
  const ListToObservable();

  @override
  ObservableList<TodoItem> fromJson(Object? json) {
    if (json == null) {
      return ObservableList<TodoItem>();
    }

    final list = (json as List).map((e) {
      return TodoItem.fromJson(e);
    });
    return ObservableList<TodoItem>.of(list);
  }

  @override
  Object? toJson(ObservableList<TodoItem>? json) {
    if (json == null) {
      return null;
    }

    final l = json.map((element) => element.toJson()).toList();
    return l;
  }
}

@JsonSerializable()
class AddGoalItemRequest {
  String? goalName;
  String? notes;
  List<TodoItem>? items;

  AddGoalItemRequest();

  factory AddGoalItemRequest.fromJson(Map<String, dynamic> json) =>
      _$AddGoalItemRequestFromJson(json);

  static List<AddGoalItemRequest> fromListJson(List listJson) {
    return listJson.map((t) => _$AddGoalItemRequestFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() {
    final map = _$AddGoalItemRequestToJson(this);
    map['items'] = items!.map((v) {
      return v.toJson();
    }).toList();
    return map;
  }
}

@JsonSerializable()
class AddGoalTodoRequest {
  String? name;
  String? notes;
  String? goalId;
  DateTime? dueDate;
  int? hour = 0;

  @ReminderTypeEnumConverter()
  ReminderTypeEnum? reminderType;

  DateTime? reminderDate;

  AddGoalTodoRequest();

  factory AddGoalTodoRequest.fromJson(Map<String, dynamic> json) =>
      _$AddGoalTodoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddGoalTodoRequestToJson(this);
}

class TodoAddModel = _TodoAddModel with _$TodoAddModel;

abstract class _TodoAddModel with Store {
  @observable
  String taskName = '';

  @observable
  DateTime? dueDate;

  @observable
  DateTime? reminderDate;

  @observable
  ReminderTypeEnum reminderType = ReminderTypeEnum.none;

  @observable
  GoalItem? selectedGoal;

  @observable
  int hour = 0;

  @computed
  bool get isValidReminder {
    if (reminderType == ReminderTypeEnum.once && reminderDate == null) {
      return false;
    } else {
      return true;
    }
  }
}

@JsonSerializable()
class AddUserActivityRequest {
  String? imageThumbnail;
  String? title;
  String? authorName;
  String? type;
  String? contentId;
  bool? isCompleted;

  AddUserActivityRequest();

  factory AddUserActivityRequest.fromJson(Map<String, dynamic> json) =>
      _$AddUserActivityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddUserActivityRequestToJson(this);
}

@JsonSerializable()
class GetLastActivityRequest {
  @JsonKey(name: 'Id')
  String? id;

  @JsonKey(name: 'IsCompleted')
  bool? isCompleted;

  @JsonKey(name: 'p')
  int? page;

  @JsonKey(name: 's')
  int? pageSize;

  @JsonKey(name: 'q')
  String? query;

  GetLastActivityRequest();

  factory GetLastActivityRequest.fromJson(Map<String, dynamic> json) =>
      _$GetLastActivityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetLastActivityRequestToJson(this);
}

@JsonSerializable()
class SetCompleteActivityRequest {
  String? contentId;
  String? type;

  SetCompleteActivityRequest();

  factory SetCompleteActivityRequest.fromJson(Map<String, dynamic> json) =>
      _$SetCompleteActivityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetCompleteActivityRequestToJson(this);
}

@JsonSerializable()
class UserActivityResponse {
  String? id;
  String? userId;
  String? imageThumbnail;
  String? title;
  String? authorName;
  String? type;
  String? contentId;
  String? isCompleted;
  late DateTime? lastAccessDt;

  UserActivityResponse();

  factory UserActivityResponse.fromJson(Map<String, dynamic> json) =>
      _$UserActivityResponseFromJson(json);

  static List<UserActivityResponse> fromListJson(List listJson) {
    return listJson.map((t) => _$UserActivityResponseFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$UserActivityResponseToJson(this);
}

@JsonSerializable()
class AssessmentModel {
  AssessmentModel();

  String? id;
  String? title;
  String? description;
  String? htmlContent;
  late DateTime? publishDate;
  late DateTime? startDate;
  late DateTime? endDate;
  late DateTime? createdDt;
  late DateTime? updatedDt;
  int? totalQuestion;
  bool? isActive;
  @JsonKey(defaultValue: [])
  List<Question>? questions;
  @JsonKey(defaultValue: 0)
  int? version;
  String? assessmentId;

  double get totalScore => questions!.fold<double>(
        0,
        (previousValue, element) =>
            previousValue + element.selectedAnswer!.score!,
      );

  factory AssessmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentModelFromJson(json);

  static List<AssessmentModel> fromListJson(List listJson) {
    return listJson.map((t) => _$AssessmentModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$AssessmentModelToJson(this);
}

@JsonSerializable()
class Question extends _Question with _$Question {
  Question();

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

abstract class _Question with Store {
  String? id;
  String? title;
  String? topic;
  String? imageUrl;
  int? type;
  String? assessmentId;
  List<Answer>? answers;

  // self assessment v2
  String? keyBehaviorId;

  @observable
  Answer? selectedAnswer;
}

@JsonSerializable()
class Answer extends _Answer with _$Answer {
  Answer();

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}

abstract class _Answer with Store {
  _Answer();

  String? id;
  String? title;
  String? imageUrl;
  int? score;
  bool? isRightAnswer;
  String? questionId;
}

@JsonSerializable()
class SubmitAssessmentRequest {
  SubmitAssessmentRequest();

  String? assessmentId;
  List<SubmitAssessmentQuestionRequest>? questions;
  @JsonKey(defaultValue: 0)
  int? version = 0;

  factory SubmitAssessmentRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitAssessmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitAssessmentRequestToJson(this);
}

@JsonSerializable()
class SubmitAssessmentQuestionRequest {
  SubmitAssessmentQuestionRequest();

  String? id;
  String? topic;
  String? answerId;
  int? score;

  // v2
  @JsonKey(name: 'keyBehavior')
  String? keyBehaviorId;

  String? assessmentId;

  factory SubmitAssessmentQuestionRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitAssessmentQuestionRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SubmitAssessmentQuestionRequestToJson(this);
}

@JsonSerializable()
class MyAssessmentModel {
  MyAssessmentModel();

  String? topic;
  int? totalScore;
  int? level;
  String? topicColor;

  factory MyAssessmentModel.fromJson(Map<String, dynamic> json) =>
      _$MyAssessmentModelFromJson(json);

  static List<MyAssessmentModel> fromListJson(List listJson) {
    return listJson.map((t) => _$MyAssessmentModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$MyAssessmentModelToJson(this);
}

@JsonSerializable()
class MyAssessmentModelV2 {
  MyAssessmentModelV2();

  String? assessmentId;
  String? assessmentTitle;
  String? topicName;
  String? description;
  int? totalScore;
  int? level;
  List<KeyBehaviorResult>? keyBehaviorResults;

  String? topicColor;
  String? iconUrl;

  int? assessmentVersion;
 

  factory MyAssessmentModelV2.fromJson(Map<String, dynamic> json) =>
      _$MyAssessmentModelV2FromJson(json);

  static List<MyAssessmentModelV2> fromListJson(List listJson) {
    return listJson.map((t) => _$MyAssessmentModelV2FromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$MyAssessmentModelV2ToJson(this);
}

@JsonSerializable()
class KeyBehaviorResult {
  KeyBehaviorResult();

  String? id;
  String? title;
  int? score;

  factory KeyBehaviorResult.fromJson(Map<String, dynamic> json) =>
      _$KeyBehaviorResultFromJson(json);

  static List<KeyBehaviorResult> fromListJson(List listJson) {
    return listJson.map((t) => _$KeyBehaviorResultFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$KeyBehaviorResultToJson(this);
}

@JsonSerializable()
class InterestModel {
  InterestModel();

  String? topicId;
  String? name;
  String? color;

  factory InterestModel.fromJson(Map<String, dynamic> json) =>
      _$InterestModelFromJson(json);

  static List<InterestModel> fromListJson(List listJson) {
    return listJson.map((t) => _$InterestModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$InterestModelToJson(this);
}

@JsonSerializable()
class UserInterestRequest {
  UserInterestRequest();

  String? topicId;

  factory UserInterestRequest.fromJson(Map<String, dynamic> json) =>
      _$UserInterestRequestFromJson(json);

  static List<UserInterestRequest> fromListJson(List listJson) {
    return listJson.map((t) => _$UserInterestRequestFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$UserInterestRequestToJson(this);
}

enum NotificationType {
  article,
  video,
  series,
  podcast,
  reminder,
}

NotificationType? parseNotificationType(String? type) {
  NotificationType? _typeEnum;
  if (type == 'article') {
    _typeEnum = NotificationType.article;
  } else if (type == 'podcast') {
    _typeEnum = NotificationType.podcast;
  } else if (type == 'video') {
    _typeEnum = NotificationType.video;
  } else if (type == 'series') {
    _typeEnum = NotificationType.series;
  } else if (type == 'reminder') {
    _typeEnum = NotificationType.reminder;
  }

  return _typeEnum;
}

@JsonSerializable()
class NotificationModel {
  NotificationModel();

  String? id;
  String? type;
  NotificationType? get typeEnum => parseNotificationType(type);

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  static List<NotificationModel> fromListJson(List listJson) {
    return listJson.map((t) => _$NotificationModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

@JsonSerializable()
class RateContentRequest {
  RateContentRequest();

  String? id;
  int? rating;
  @BrowseTypeConverter()
  BrowseType? contentType;

  factory RateContentRequest.fromJson(Map<String, dynamic> json) =>
      _$RateContentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RateContentRequestToJson(this);
}

class BrowseTypeConverter implements JsonConverter<BrowseType?, String> {
  const BrowseTypeConverter();

  @override
  BrowseType? fromJson(String? json) {
    return BrowseType.values.firstWhereOrNull(
      (element) => getBrowseTypeName(element) == json,
    );
  }

  @override
  String toJson(BrowseType? object) {
    return getBrowseTypeName(object);
  }
}

@JsonSerializable()
class FaqModel {
  FaqModel();

  String? id;
  String? question;
  String? answer;
  int? order;
  late DateTime? createdDt;
  late DateTime? updatedDt;

  factory FaqModel.fromJson(Map<String, dynamic> json) =>
      _$FaqModelFromJson(json);

  static List<FaqModel> fromListJson(List listJson) {
    return listJson.map((t) => _$FaqModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$FaqModelToJson(this);
}

@JsonSerializable()
class TermConditionModel {
  TermConditionModel();

  String? id;
  String? title;
  String? content;
  bool? isActive;
  late DateTime? createdDt;
  late DateTime? updatedDt;

  factory TermConditionModel.fromJson(Map<String, dynamic> json) =>
      _$TermConditionModelFromJson(json);

  static List<TermConditionModel> fromListJson(List listJson) {
    return listJson.map((t) => _$TermConditionModelFromJson(t)).toList();
  }

  Map<String, dynamic> toJson() => _$TermConditionModelToJson(this);
}

@JsonSerializable()
class FindCompanyResponse {
  FindCompanyResponse();

  String? id;
  String? companyName;

  factory FindCompanyResponse.fromJson(Map<String, dynamic> json) =>
      _$FindCompanyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FindCompanyResponseToJson(this);
}

@JsonSerializable()
class EditGoalRequest {
  EditGoalRequest();

  String? id;
  String? name;
  String? notes;

  factory EditGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$EditGoalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EditGoalRequestToJson(this);
}
