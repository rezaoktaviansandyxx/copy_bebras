import 'dart:async';
import 'dart:convert';

import 'package:dio/src/response.dart';
import 'package:dio/src/dio.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class AppClientMockupServices extends AppClientServices {
  final goals = Map<String, AddGoalItemRequest>();

  BaseResponse<T> createResponse<T>(
    T value, [
    int statusCode = 200,
  ]) {
    return BaseResponse<T>()
      ..statusCode = statusCode
      ..payload = value;
  }

  // @override
  // FutureOr<Response> addActivity(AddUserActivityRequest request,
  //     {CancelToken cancelToken}) {
  //   return Response()..statusCode = 200;
  // }

  // @override
  // FutureOr<BaseResponse<String>> addGoal(
  //   AddGoalItemRequest request, {
  //   CancelToken cancelToken,
  // }) {
  //   final id = _uuid.v4();
  //   goals.putIfAbsent(
  //     id,
  //     () => request,
  //   );
  //   return createResponse(id);
  // }

  // @override
  // FutureOr<BaseResponse<String>> addTodoInGoal(
  //   String goalId,
  //   AddGoalTodoRequest request, {
  //   CancelToken cancelToken,
  // }) {
  //   if (goals.containsKey(goalId) == false) {
  //     throw 'not found';
  //   }

  //   final todoId = _uuid.v4();
  //   final goal = goals[goalId];
  //   goal.items.add(
  //     TodoItem()
  //       ..id = todoId
  //       ..dueDate = request.dueDate
  //       ..goalName = goal.goalName
  //       ..hour = request.hour
  //       ..isCompleted = false
  //       ..isRecurring = false
  //       ..name = request.name
  //       ..notes = request.notes
  //       ..reminderDate = request.reminderDate
  //       ..reminderType = request.reminderType,
  //   );
  //   return createResponse(todoId);
  // }

  // @override
  // FutureOr<BaseResponse<LoginResponse>> auth(
  //   LoginRequest request, {
  //   CancelToken cancelToken,
  // }) {
  //   return createResponse(
  //     LoginResponse()
  //       ..token = 'token'
  //       ..tokenScheme = 'Bearer',
  //   );
  // }

  //   @override
  //   FutureOr<Response> changePassword(String oldPassword, String newPassword, String confirmNewPassword, {CancelToken cancelToken}) {
  //     // TODO: implement changePassword
  //     throw UnimplementedError();
  //   }

  // @override
  // FutureOr<Response<Map<String, dynamic>>> deleteGoal(
  //   String goalsId, {
  //   CancelToken cancelToken,
  // }) {
  //   return Response<Map<String, dynamic>>()..statusCode = 200;
  // }

  // @override
  // FutureOr<Response> deleteTodo(
  //   String todoId, {
  //   CancelToken cancelToken,
  // }) {
  //   final todosToDelete = List<Tuple2<String, String>>();
  //   for (var item in goals.entries) {
  //     for (var item2 in item.value.items) {
  //       if (item2.id == todoId) {
  //         todosToDelete.add(Tuple2(item.key, item2.id));
  //       }
  //     }
  //   }

  //   for (var item in todosToDelete) {
  //     final goal = goals[item.item1];
  //     goal.items.removeWhere(
  //       (element) => element.id == item.item2,
  //     );
  //   }
  // }

  //   @override
  //   // TODO: implement dio
  //   Dio get dio => throw UnimplementedError();

  //   @override
  //   FutureOr<Response<Map<String, >>> editTodo(TodoItem todoItem, {CancelToken cancelToken}) {
  //     // TODO: implement editTodo
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<Response> forgotPassword(String email, {CancelToken cancelToken}) {
  //     // TODO: implement forgotPassword
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<List<ArticleItem>>> getArticle(GetArticleRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement getArticle
  //     throw UnimplementedError();
  //   }

  @override
  FutureOr<BaseResponse<List<AssessmentModel>>> getAssessment({
    int page = 1,
    int sizePage = 20,
    String? query,
    int? version,
    CancelToken? cancelToken,
  }) {
    final json = """
    [
      {
            "id": "08d8686b-f079-4f72-837c-335c00bb7070",
            "title": "Strategic Management",
            "description": "Strategic Management",
            "htmlContent": "<p>Strategic Management</p>",
            "createdDt": "2020-10-04T13:46:47.981853",
            "totalQuestion": 4,
            "isActive": false,
            "topicId": "e290a015-0592-4e17-8093-cebfa3643728",
            "version": 1
        },
        {
            "id": "08d8081d-b123-44c2-8f3a-155e838faf42",
            "title": "SELF ASSESSMENT",
            "description": "Hi Good People,Sekarang kita coba lakukan self assessment mengenai kompetensi kita selama ini. Berikut ini ada beberapa kompetensi yang penting untuk di miliki karyawan di suatu perusahaan. Sekarang renungkan sejenak, seberapa sering dan konsisten anda dalam mengimplementasi perilaku-perilaku pada masing-masing level dalam setiap kompetensi di keseharian anda. Pilihlah situasi yang paling menggambarkan diri anda saat ini pada masing-masing kompetensi.",
            "htmlContent": "fdasf",
            "createdDt": "2020-06-04T00:24:49.266418",
            "updatedDt": "2020-06-11T08:10:01.963258",
            "totalQuestion": 24,
            "isActive": false,
            "version": 0
        }
    ]
    """;
    final _jsonDecode = jsonDecode(json);
    final list = AssessmentModel.fromListJson(_jsonDecode);
    return createResponse(
      list,
    );
  }

  // @override
  // FutureOr<BaseResponse<List<BrowseModel>>> getBrowseSearch({
  //   GetBrowseRequest request,
  //   CancelToken cancelToken,
  // }) {
  //   return createResponse(List<BrowseModel>.from([
  //     BrowseModel()
  //       ..id = _uuid.v4()
  //       ..title = 'Article'
  //       ..type = BrowseType.article.toString(),
  //   ]));
  // }

  //   @override
  //   FutureOr<BaseResponse<List<ActivityItem>>> getCompletedActivity(GetActivityRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement getCompletedActivity
  //     throw UnimplementedError();
  //   }

  // @override
  // FutureOr<BaseResponse<ArticleDetailItem>> getDetailArticle(String id,
  //     {CancelToken cancelToken}) {
  //   return createResponse(
  //     ArticleDetailItem()
  //       ..title = 'Title'
  //       ..htmlContent =
  //           '<div>Researchers found that 3 skills provide the necessary connection between the process part of changeand the people part of change. These 3 C’s unite effective change leadership:'
  //       ..todoListArr = ['1', '2', '3'],
  //   );
  // }

  @override
  FutureOr<BaseResponse<AssessmentModel>> getDetailAssessment(
    String? id, {
    CancelToken? cancelToken,
  }) {
    final json = """
    [
      {
        "id": "08d8081d-b123-44c2-8f3a-155e838faf42",
        "title": "SELF ASSESSMENT mockup",
        "description": "Hi Good People, Sekarang kita coba lakukan self assessment mengenai kompetensi kita selama ini. Berikut ini ada beberapa kompetensi yang penting untuk di miliki karyawan di suatu perusahaan. Sekarang renungkan sejenak, seberapa sering dan konsisten anda dalam mengimplementasi perilaku-perilaku pada masing-masing level dalam setiap kompetensi di keseharian anda. Pilihlah situasi yang paling menggambarkan diri anda saat ini pada masing-masing kompetensi.",
        "htmlContent": "fdaf",
        "publishDate": "2020-06-04T07:24:49.148294",
        "startDate": "2020-06-05T00:00:00",
        "endDate": "2020-06-30T00:00:00",
        "totalQuestion": 0,
        "isActive": true,
        "version": 0,
        "questions": [
            {
                "id": "c4152bc9-74f1-4c9a-a511-2661de940fee",
                "topic": "Creativity & Inovation",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "3d71d3d6-08f6-4325-af87-40be6deb0409",
                        "title": "Saya mampu melihat masalah dari berbagai sudut pandang",
                        "score": 2,
                        "questionId": "c4152bc9-74f1-4c9a-a511-2661de940fee"
                    },
                    {
                        "id": "4b833380-88e0-4e63-a8d4-52d46079325f",
                        "title": "Saya aktif menggali sudut pandang orang lain untuk mendapatkan cara menyelesaikan tugas lebih efektif dan efisien",
                        "score": 3,
                        "questionId": "c4152bc9-74f1-4c9a-a511-2661de940fee"
                    },
                    {
                        "id": "5660ceda-6a04-45d8-b196-13f3bbf05e17",
                        "title": "Saya selalu menggunakan cara - cara yang saya kenali  dalam menyelesaikan permasalahan pekerjaan saya",
                        "score": 0,
                        "questionId": "c4152bc9-74f1-4c9a-a511-2661de940fee"
                    },
                    {
                        "id": "58f57536-929e-44cb-b29b-4cfec8a55f8a",
                        "title": "Saya terbuka dalam berbagai ide dan cara-cara baru dalam menyelesaikan masalah",
                        "score": 1,
                        "questionId": "c4152bc9-74f1-4c9a-a511-2661de940fee"
                    },
                    {
                        "id": "79b68d0d-2ad4-42a9-8722-e6ab70a55b8e",
                        "title": "Saya mampu menginspirasi orang lain untuk menerapkan cara-cara baru.",
                        "score": 4,
                        "questionId": "c4152bc9-74f1-4c9a-a511-2661de940fee"
                    }
                ]
            },
            {
                "id": "95092a38-ccc2-4ede-828e-50f16d0c5651",
                "topic": "Creativity & Inovation",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "01fc97ce-95f3-4031-ac9f-c17556024c8a",
                        "title": "Saya konsisten mengeksplorasi ide dan teknologi baru di organisasi maupun tren global.",
                        "score": 4,
                        "questionId": "95092a38-ccc2-4ede-828e-50f16d0c5651"
                    },
                    {
                        "id": "3dce272d-ac63-4c47-b921-5a335894ed1b",
                        "title": "Menerima langkah alternatif untuk menyelesaikan permasalahan di unit atau lingkungan kerjanya.",
                        "score": 1,
                        "questionId": "95092a38-ccc2-4ede-828e-50f16d0c5651"
                    },
                    {
                        "id": "7288ddb6-9b54-4f88-9238-b73eb0199ef3",
                        "title": "Saya mampu memberi saran dan metode baru untuk menyelesaikan masalah di tim kerja lintas bagian dalam 1 unit.",
                        "score": 2,
                        "questionId": "95092a38-ccc2-4ede-828e-50f16d0c5651"
                    },
                    {
                        "id": "da139c72-20fe-4b26-95e9-fab0e5d2eafb",
                        "title": "Saya mencari informasi baru dari berbagai sumber untuk menghasilkan cara yang berbeda dalam menyelesaikan masalah.",
                        "score": 3,
                        "questionId": "95092a38-ccc2-4ede-828e-50f16d0c5651"
                    },
                    {
                        "id": "f8474108-e781-4eb1-b835-54a196de1fa4",
                        "title": "Saya menilai cara saya bekerja adalah cara yang terbaik dibandingkan dengan rekan kerja saya.",
                        "score": 0,
                        "questionId": "95092a38-ccc2-4ede-828e-50f16d0c5651"
                    }
                ]
            },
            {
                "id": "fc4ec270-3eea-4584-943c-18b9bdb58559",
                "topic": "Creativity & Inovation",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "18970d7a-a1e1-474e-897d-98fccccc4fd9",
                        "title": "Saya memberikan saran metode, ide dan solusi-solusi baru yang relevan untuk mencapai tujuan perusahaan dalam mengantisipasi perubahan",
                        "score": 4,
                        "questionId": "fc4ec270-3eea-4584-943c-18b9bdb58559"
                    },
                    {
                        "id": "900c64b6-c896-491a-9aeb-cb042bef5bfd",
                        "title": "Saya mampu mengenali perubahan di unit kerja",
                        "score": 1,
                        "questionId": "fc4ec270-3eea-4584-943c-18b9bdb58559"
                    },
                    {
                        "id": "cc319bd6-e371-4896-883b-5e8b050ae895",
                        "title": "Saya merasa segala proses pekerjaan telah berjalan semestinya dan telah ada mekanisme dalam mengerjakan proses kerja.",
                        "score": 0,
                        "questionId": "fc4ec270-3eea-4584-943c-18b9bdb58559"
                    },
                    {
                        "id": "e170066a-813e-46e3-918f-2bab53dd545d",
                        "title": "Saya mampu memotivasi orang lain untuk memberi ide dalam menyelesaikan masalah unit kerja",
                        "score": 3,
                        "questionId": "fc4ec270-3eea-4584-943c-18b9bdb58559"
                    },
                    {
                        "id": "e65ff9da-5d8b-4b99-9f7b-557d8a0f1b04",
                        "title": "Saya mampu memberi saran untuk mengubah pola kerja lama di bagian saya.",
                        "score": 2,
                        "questionId": "fc4ec270-3eea-4584-943c-18b9bdb58559"
                    }
                ]
            },
            {
                "id": "0d4162da-009c-492e-9f26-a85ec42538fd",
                "topic": "Strategic Management",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "498b317f-67cf-493b-a9c3-bebf95d1685a",
                        "title": "Saya mampu menggunakan pemahaman saya untuk mengidentifikasi tugas harian yang sejalan dengan unit tempat saya bekerja.",
                        "score": 1,
                        "questionId": "0d4162da-009c-492e-9f26-a85ec42538fd"
                    },
                    {
                        "id": "66dea577-21cc-4c1d-a5df-f9bb43b757fe",
                        "title": "Saya mampu menetapkan tujuan tim yang selaras dengan unit kerja  ",
                        "score": 2,
                        "questionId": "0d4162da-009c-492e-9f26-a85ec42538fd"
                    },
                    {
                        "id": "90404270-ad0d-43e9-9645-d693a7f70091",
                        "title": "Saya mampu mencari berbagai sumber daya dan mengelolanya secara tepat demi mencapai sasaran divisi/direktorat",
                        "score": 3,
                        "questionId": "0d4162da-009c-492e-9f26-a85ec42538fd"
                    },
                    {
                        "id": "c1752185-37c6-438f-af7e-74ae764a1b19",
                        "title": "Saya terlibat dan mampu dalam membuat visi strategis perusahaan",
                        "score": 4,
                        "questionId": "0d4162da-009c-492e-9f26-a85ec42538fd"
                    },
                    {
                        "id": "e766126a-a870-43fe-ad17-e78fba989a18",
                        "title": "Saya mangerjakan tugas sesuai dengan arahan harian dari atasan saya.",
                        "score": 0,
                        "questionId": "0d4162da-009c-492e-9f26-a85ec42538fd"
                    }
                ]
            },
            {
                "id": "b63229da-046a-441f-a715-3e7cae10b868",
                "topic": "Strategic Management",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "1110f211-9c0b-4993-a2f9-dac3eecb8cdf",
                        "title": "Saya memonitor dan mengevaluasi kinerja pribadi dan tim agar selaras dengan tujuan tim ",
                        "score": 2,
                        "questionId": "b63229da-046a-441f-a715-3e7cae10b868"
                    },
                    {
                        "id": "5ab2c6d9-d9fe-4ab9-8088-90b07d769968",
                        "title": "Saya mampu menggunakan sumber daya yang ada untuk menjalankan tugas.",
                        "score": 1,
                        "questionId": "b63229da-046a-441f-a715-3e7cae10b868"
                    },
                    {
                        "id": "8de8ee3d-4138-4727-897a-9ad19d1b7b6b",
                        "title": "Saya terlibat dan mampu dalam membuat visi strategis perusahaan",
                        "score": 0,
                        "questionId": "b63229da-046a-441f-a715-3e7cae10b868"
                    },
                    {
                        "id": "f1b7d689-af8b-4f3e-a730-3876d5b7167d",
                        "title": "Saya mengevaluasi dan memperbaiki bisnis proses yang menambah nilai perusahaan  ",
                        "score": 4,
                        "questionId": "b63229da-046a-441f-a715-3e7cae10b868"
                    },
                    {
                        "id": "f97e538b-77fb-4966-86ff-8e00e0b1e9d7",
                        "title": "Saya mampu mengomunikasikan visi dan nilai-nilai perusahaan kepada pihak-pihak terkait di luar perusahaan",
                        "score": 3,
                        "questionId": "b63229da-046a-441f-a715-3e7cae10b868"
                    }
                ]
            },
            {
                "id": "6fed72a9-1f48-4422-9431-cb686782a9ca",
                "topic": "Strategic Management",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "0ed797ad-5ec0-44eb-a47b-158ced390f5c",
                        "title": "Saya mencari dan mengalokasikan sumber daya di seluruh unit dan juga eksternal perusahaan untuk mencapai visi perusahaan",
                        "score": 4,
                        "questionId": "6fed72a9-1f48-4422-9431-cb686782a9ca"
                    },
                    {
                        "id": "39796424-b0ee-410d-9a6d-4ed2d725b4fb",
                        "title": "Saya mampu menginisiasi pola kerja sama dengan berbagai pihak di dalam dan di luar organisasi  ",
                        "score": 3,
                        "questionId": "6fed72a9-1f48-4422-9431-cb686782a9ca"
                    },
                    {
                        "id": "a1d2782c-0035-4cf2-8172-8761c67cdb20",
                        "title": "Saya mampu menetapkan strategi disertai mengalokasikan sumber daya yang beragam dalam menyelesaikan tugas di tim",
                        "score": 2,
                        "questionId": "6fed72a9-1f48-4422-9431-cb686782a9ca"
                    },
                    {
                        "id": "e91347e3-0b65-49ad-85cc-39ffb4577f70",
                        "title": "Saya kurang memahami cara melakukan evaluasi kinerja pribadi",
                        "score": 0,
                        "questionId": "6fed72a9-1f48-4422-9431-cb686782a9ca"
                    },
                    {
                        "id": "f207e53e-a30a-42e2-8fed-17d8167b5e8a",
                        "title": "Saya mengevaluasi kerja saya agar selaras dengan tujuan operasional unit",
                        "score": 1,
                        "questionId": "6fed72a9-1f48-4422-9431-cb686782a9ca"
                    }
                ]
            },
            {
                "id": "1c864b2b-50bf-48fc-93d8-4871a9b72048",
                "topic": "Customer Orientation",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "06044d6d-f497-4c74-abf9-c59582462bdc",
                        "title": "Saya mampu membangun sistem dan kebijakan untuk meningkatkan pelayanan jangka panjang dalam area yang luas  ",
                        "score": 4,
                        "questionId": "1c864b2b-50bf-48fc-93d8-4871a9b72048"
                    },
                    {
                        "id": "59ef150e-2a37-4f8a-8318-ada94937b173",
                        "title": "Saya melayani pelanggan sesuai dengan SOP",
                        "score": 1,
                        "questionId": "1c864b2b-50bf-48fc-93d8-4871a9b72048"
                    },
                    {
                        "id": "729f1a78-194b-41d4-b155-8af9110b1a6a",
                        "title": "Saya memprioritaskan layanan pelanggan dan mampu menentukan strategi yg beragam",
                        "score": 3,
                        "questionId": "1c864b2b-50bf-48fc-93d8-4871a9b72048"
                    },
                    {
                        "id": "7427fa39-0639-427f-833c-34aa573fe2bc",
                        "title": "Saya memahami jenis layanan yang sesuai dengan kebutuhan pelanggan",
                        "score": 2,
                        "questionId": "1c864b2b-50bf-48fc-93d8-4871a9b72048"
                    },
                    {
                        "id": "7b554ae8-6478-4d75-9344-5860abeff23c",
                        "title": "Saya melayani pelanggan dengan menggunakan sudut pandang diri sendiri",
                        "score": 0,
                        "questionId": "1c864b2b-50bf-48fc-93d8-4871a9b72048"
                    }
                ]
            },
            {
                "id": "ddf3995f-6478-42db-823e-b5cf2b157e35",
                "topic": "Customer Orientation",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "5b6b6e09-3ae0-41fc-bcae-8cd18824c918",
                        "title": "Saya selalu menggunakan cara sama dalam menangani keluhan pelanggan.",
                        "score": 0,
                        "questionId": "ddf3995f-6478-42db-823e-b5cf2b157e35"
                    },
                    {
                        "id": "6384877d-02f0-4321-822d-d59e8a16da8e",
                        "title": "Saya selalu memastikan kebutuhan pelanggan dengan mengontaknya dan menggali informasi ",
                        "score": 1,
                        "questionId": "ddf3995f-6478-42db-823e-b5cf2b157e35"
                    },
                    {
                        "id": "6ab5f6d5-c0d6-458d-8423-4df8ec8c7823",
                        "title": "Saya mengelola proses layanan pelanggan untuk memenuhi kebutuhan jangka panjangnya ",
                        "score": 3,
                        "questionId": "ddf3995f-6478-42db-823e-b5cf2b157e35"
                    },
                    {
                        "id": "7ffad4bc-f841-48d6-9740-9972f99f5e01",
                        "title": "Saya memberikan saran dan beragam alternatif untuk memaksimalkan layanan - Saya aktif mencari cara baru untuk meningkatkan kinerja pelayanan",
                        "score": 2,
                        "questionId": "ddf3995f-6478-42db-823e-b5cf2b157e35"
                    },
                    {
                        "id": "f45eeb8f-c101-43b8-a687-aa3642fa884c",
                        "title": "Saya mampu mengelola komunitas untuk menghasilkan nilai lebih bagi pelanggan Saya memahami dan mengelola kemitraan strategis demi meningkatkan layanan jangka panjang",
                        "score": 4,
                        "questionId": "ddf3995f-6478-42db-823e-b5cf2b157e35"
                    }
                ]
            },
            {
                "id": "7034aef5-c14b-4226-8ed9-fca2619c99b9",
                "topic": "Customer Orientation",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "1f5709f1-11c6-4b8b-861f-ddd6efbb85da",
                        "title": "Saya memahami dan mengelola kemitraan strategis demi meningkatkan layanan jangka panjang",
                        "score": 4,
                        "questionId": "7034aef5-c14b-4226-8ed9-fca2619c99b9"
                    },
                    {
                        "id": "bde969d1-9eb1-415e-960f-50b91522739d",
                        "title": "Saya belum selalu tepat dalam menerjemahkan data terkait kebutuhan pelanggan ",
                        "score": 0,
                        "questionId": "7034aef5-c14b-4226-8ed9-fca2619c99b9"
                    },
                    {
                        "id": "cf0d7d98-d549-47ea-8dc0-9010b45b0437",
                        "title": "Saya mampu menerjemahkan data untuk memahami situasi pelanggan",
                        "score": 1,
                        "questionId": "7034aef5-c14b-4226-8ed9-fca2619c99b9"
                    },
                    {
                        "id": "da68e652-cb76-4c6c-98b5-864671e7b3af",
                        "title": "Saya aktif mencari cara baru untuk meningkatkan kinerja pelayanan",
                        "score": 2,
                        "questionId": "7034aef5-c14b-4226-8ed9-fca2619c99b9"
                    },
                    {
                        "id": "f60d6225-4e95-499b-8016-1394cb504c31",
                        "title": "Saya mengembangkan metode untuk mendapatkan umpan balik pelanggan demi meningkatkan layanan",
                        "score": 3,
                        "questionId": "7034aef5-c14b-4226-8ed9-fca2619c99b9"
                    }
                ]
            },
            {
                "id": "138ac88c-7d4a-494f-85ca-9b8cbfbff91f",
                "topic": "Execution-Focus",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "79ad04d8-d03d-42fe-9b30-358ee0f11206",
                        "title": "Saya mengidentifikasi risiko dan mitigasinya di unit sendiri dan yang lain",
                        "score": 3,
                        "questionId": "138ac88c-7d4a-494f-85ca-9b8cbfbff91f"
                    },
                    {
                        "id": "90d7ff69-39f0-4b98-98ab-c82197bc5954",
                        "title": "Saya menerima tanggung jawab atas kesalahan pribadi",
                        "score": 1,
                        "questionId": "138ac88c-7d4a-494f-85ca-9b8cbfbff91f"
                    },
                    {
                        "id": "ab0b6c44-0664-44bf-a26b-31fe7f3b22fa",
                        "title": "Saya menunggu instruksi atau persetujuan atasan dalam bertindak.",
                        "score": 0,
                        "questionId": "138ac88c-7d4a-494f-85ca-9b8cbfbff91f"
                    },
                    {
                        "id": "c48870d4-5dd2-4922-80ad-fc34578ada26",
                        "title": "Saya menciptakan lingkungan yang mendukung untuk pengambilan keputusan yang berisiko",
                        "score": 4,
                        "questionId": "138ac88c-7d4a-494f-85ca-9b8cbfbff91f"
                    },
                    {
                        "id": "eca65335-ecb1-40c3-8a8a-31460e033891",
                        "title": "Saya menerima tanggung jawab yang lebih besar dari area kerja saya",
                        "score": 2,
                        "questionId": "138ac88c-7d4a-494f-85ca-9b8cbfbff91f"
                    }
                ]
            },
            {
                "id": "d9cc483a-8b9a-4a38-8a37-069cb31a75e3",
                "topic": "Execution-Focus",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "37ac99c8-0d66-404d-b3c9-075b8449dd58",
                        "title": "Saya menggunakan pengalaman saya saja dalam mengambil keputusan.",
                        "score": 0,
                        "questionId": "d9cc483a-8b9a-4a38-8a37-069cb31a75e3"
                    },
                    {
                        "id": "430f10d9-d67f-471e-b69a-ec78b2fe1ae7",
                        "title": "Saya mampu mengidentifikasi risiko di tim kerja dan mengambil risiko yang menantang",
                        "score": 2,
                        "questionId": "d9cc483a-8b9a-4a38-8a37-069cb31a75e3"
                    },
                    {
                        "id": "6f5ad379-e3f1-4201-aec6-61396aac899e",
                        "title": "Saya merumuskan kebijakan untuk pengambilan keputusan dan mitigasi bagi perusahaan Saya mampu membuat keputusan di lingkungan yang mudah berubah",
                        "score": 4,
                        "questionId": "d9cc483a-8b9a-4a38-8a37-069cb31a75e3"
                    },
                    {
                        "id": "7b3c386e-ea2c-4696-a6a8-e586baf83f88",
                        "title": "Saya membuat keputusan strategis yang berisiko dengan mempertimbangkan sejumlah faktor dan berdampak signifikan bagi unit/divisi",
                        "score": 3,
                        "questionId": "d9cc483a-8b9a-4a38-8a37-069cb31a75e3"
                    },
                    {
                        "id": "92a14db5-ff42-4db8-84a4-b0d89039f9db",
                        "title": "Saya mengikuti arahan yang diberikan atasan ",
                        "score": 1,
                        "questionId": "d9cc483a-8b9a-4a38-8a37-069cb31a75e3"
                    }
                ]
            },
            {
                "id": "4b384aac-eeb3-43ce-9abe-3674c89dd244",
                "topic": "Execution-Focus",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "0cbf8681-cbb5-4a19-8e37-53377eba4245",
                        "title": "Saya mampu mengambil keputusan dengan pertimbangan dari berbagai faktor",
                        "score": 2,
                        "questionId": "4b384aac-eeb3-43ce-9abe-3674c89dd244"
                    },
                    {
                        "id": "1645e917-2199-4838-b3c0-f1c9477cdc55",
                        "title": "Saya bersedia mengambil tanggung jawab atas kesalahan/kegagalan di unit/divisi",
                        "score": 3,
                        "questionId": "4b384aac-eeb3-43ce-9abe-3674c89dd244"
                    },
                    {
                        "id": "2e31853e-1494-4460-93d7-f143c52b65e2",
                        "title": "Saya mampu mengidentifikasi risiko dari tugas yang diberikan dan mengambil risiko yang paling minim",
                        "score": 1,
                        "questionId": "4b384aac-eeb3-43ce-9abe-3674c89dd244"
                    },
                    {
                        "id": "93e9daa0-acfe-41e7-ae48-d66555945c85",
                        "title": "Saya mampu membuat keputusan di lingkungan yang mudah berubah",
                        "score": 4,
                        "questionId": "4b384aac-eeb3-43ce-9abe-3674c89dd244"
                    },
                    {
                        "id": "fc5c4d76-9122-485b-8d64-85cd14c2e6b9",
                        "title": "Pekerjaan yang saya lakukan tidak memiliki risiko.",
                        "score": 0,
                        "questionId": "4b384aac-eeb3-43ce-9abe-3674c89dd244"
                    }
                ]
            },
            {
                "id": "130f1b87-cfb8-4a70-bcf6-fa0868ff0b31",
                "topic": "Change Leadership",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "058180e1-8d26-4ef3-a0b8-934d7b05bee0",
                        "title": "Saya membuat kebijakan di perusahaan yang mendorong perubahan",
                        "score": 4,
                        "questionId": "130f1b87-cfb8-4a70-bcf6-fa0868ff0b31"
                    },
                    {
                        "id": "7c4996fe-d798-45c9-96c9-a9927a3f1eea",
                        "title": "Saya menggunakan gaya interpersonal untuk memperoleh dukungan atas perubahan dan mendorong orang lain untuk berubah",
                        "score": 3,
                        "questionId": "130f1b87-cfb8-4a70-bcf6-fa0868ff0b31"
                    },
                    {
                        "id": "abf05993-8dba-4dcd-ad2a-b07be5bc9d85",
                        "title": "Saya menerima perubahan yang ada di lingkup pekerjaan.",
                        "score": 1,
                        "questionId": "130f1b87-cfb8-4a70-bcf6-fa0868ff0b31"
                    },
                    {
                        "id": "d43acde2-f13b-4ca7-abe0-e2aa35aa2cc2",
                        "title": "Saya mengarahkan diri sendiri dan orang lain di dalam tim untuk menetapkan target dan strateginya, serta merealisasikan kebutuhan perubahan",
                        "score": 2,
                        "questionId": "130f1b87-cfb8-4a70-bcf6-fa0868ff0b31"
                    },
                    {
                        "id": "ed65c02c-4d5c-4aed-9624-3bca35e07d31",
                        "title": "Saya mengalami kesulitan ketika ada hal yang harus saya rubah dari cara kerja sebelumnya.",
                        "score": 0,
                        "questionId": "130f1b87-cfb8-4a70-bcf6-fa0868ff0b31"
                    }
                ]
            },
            {
                "id": "7918ccf4-7183-4cf4-a523-c17f22a39347",
                "topic": "Change Leadership",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "00bd1d2c-fa91-4b3f-8fe0-8a8aa7b73697",
                        "title": "Secara formal saya meyakinkan orang lain mengenai pentingnya melakukan perubahan dalam penyelesaian tugas",
                        "score": 1,
                        "questionId": "7918ccf4-7183-4cf4-a523-c17f22a39347"
                    },
                    {
                        "id": "25380bce-32bf-4ab2-a126-5a462437541b",
                        "title": "Saya mampu berbagi informasi tentang keberhasilan perubahan di perusahaan/organisasi",
                        "score": 4,
                        "questionId": "7918ccf4-7183-4cf4-a523-c17f22a39347"
                    },
                    {
                        "id": "7a7e728d-48eb-47aa-a91b-2364720080ff",
                        "title": "Saya belum selalu berhasil meyakinkan orang lain untuk merubah cara kerjanya",
                        "score": 0,
                        "questionId": "7918ccf4-7183-4cf4-a523-c17f22a39347"
                    },
                    {
                        "id": "9bbc4164-b61c-48c2-aa8b-83f07d5906e0",
                        "title": "Saya menginisiasi perubahan yang ada di unit dan memastikan tindakan perubahan muncul dari diri sendiri dan orang-orang di dalam tim",
                        "score": 3,
                        "questionId": "7918ccf4-7183-4cf4-a523-c17f22a39347"
                    },
                    {
                        "id": "bd17b8e9-3395-443a-bd94-c73375fa6eb9",
                        "title": "Saya berusaha meyakinkan orang lain tentang dampak dari perubahan terhadap unit ",
                        "score": 2,
                        "questionId": "7918ccf4-7183-4cf4-a523-c17f22a39347"
                    }
                ]
            },
            {
                "id": "8cc9fda3-3d5c-4e61-92f8-b2df5c566510",
                "topic": "Change Leadership",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "8f1589c2-41f6-492b-a77d-ef7fc3838f5e",
                        "title": "Saya menerapkan pola perubahan yang telah teruji kepada diri sendiri dan orang lain dan memastikan perilaku tetap muncul secara berkelanjutan",
                        "score": 2,
                        "questionId": "8cc9fda3-3d5c-4e61-92f8-b2df5c566510"
                    },
                    {
                        "id": "eb332a64-1e90-4c36-b579-c46325ed50bf",
                        "title": "Saya mengarahkan diri untuk berubah sesuai kebutuhan dan tuntutan pekerjaan saya.",
                        "score": 1,
                        "questionId": "8cc9fda3-3d5c-4e61-92f8-b2df5c566510"
                    },
                    {
                        "id": "f21d3b4c-7557-4d40-9c72-349005e4e4c3",
                        "title": "Saya mampu mengembangkan pendekatan kepemimpinan yang tepat agar tujuan organisasi tercapai",
                        "score": 4,
                        "questionId": "8cc9fda3-3d5c-4e61-92f8-b2df5c566510"
                    },
                    {
                        "id": "f888be3a-11db-4ee1-b67b-00d482ad8db1",
                        "title": "Saya perlu waktu untuk merubah cara kerja saya yang lama ",
                        "score": 0,
                        "questionId": "8cc9fda3-3d5c-4e61-92f8-b2df5c566510"
                    },
                    {
                        "id": "fa1e6ba6-84a6-4ed2-a6b6-ed14c8422511",
                        "title": "Saya secara aktif mampu menggali sudut pandang orang lain dalam mencari cara baru yg lebih efektif dan efisien",
                        "score": 3,
                        "questionId": "8cc9fda3-3d5c-4e61-92f8-b2df5c566510"
                    }
                ]
            },
            {
                "id": "3ffdbe12-1a3a-4e93-a30b-db158257ff45",
                "topic": "Strategic relationship",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "1a45eda3-def5-4b6a-a0cf-8196048688be",
                        "title": "Saya mampu membangun kemitraan untuk mendukung pengembangan bisnis",
                        "score": 3,
                        "questionId": "3ffdbe12-1a3a-4e93-a30b-db158257ff45"
                    },
                    {
                        "id": "58785d9e-fc6e-4664-9759-b4ffedc49370",
                        "title": "Saya menjalin komunikasi dengan pihak lain dan memberi saran yang relevan, bahkan saling menguntungkan kedua belah pihak",
                        "score": 2,
                        "questionId": "3ffdbe12-1a3a-4e93-a30b-db158257ff45"
                    },
                    {
                        "id": "a5e39578-cb4c-481f-abf8-e86fde69da7a",
                        "title": "Saya memelihara kontak pribadi dan melakukan komunikasi dengan rekan kerja yang terkait dengan pekerjaan saya  ",
                        "score": 1,
                        "questionId": "3ffdbe12-1a3a-4e93-a30b-db158257ff45"
                    },
                    {
                        "id": "f4cf6531-9a5c-4dd9-8911-2645986b91d0",
                        "title": "Saya mengontak rekan kerja atau pihak lain ketika saya butuhkan dalam penyelesaian pekerjaan saya.",
                        "score": 0,
                        "questionId": "3ffdbe12-1a3a-4e93-a30b-db158257ff45"
                    },
                    {
                        "id": "ff6bead2-328a-4d32-87b3-b2102a5c693f",
                        "title": "Saya mampu menjalin kemitraan untuk menghasilkan peluang bisnis yang berjangka panjang",
                        "score": 4,
                        "questionId": "3ffdbe12-1a3a-4e93-a30b-db158257ff45"
                    }
                ]
            },
            {
                "id": "f92efc6f-d85a-4ba6-a7c2-1782b73dcff9",
                "topic": "Strategic relationship",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "0662bde0-d0a0-4ebf-8a52-f82ec321782e",
                        "title": "Saya mampu meningkatkan jejaring dengan pihak di luar organisasi untuk mencapai tujuan perusaaan",
                        "score": 3,
                        "questionId": "f92efc6f-d85a-4ba6-a7c2-1782b73dcff9"
                    },
                    {
                        "id": "2172f95f-fcc8-4a12-8213-71d0fd1b343f",
                        "title": "Saya merasa tidak perlu menjalin relasi dengan pihak lain, yang terpenting bagi saya adalah pekerjaan saya selesai.",
                        "score": 0,
                        "questionId": "f92efc6f-d85a-4ba6-a7c2-1782b73dcff9"
                    },
                    {
                        "id": "b1036679-07f1-490f-8e69-5a0d7911c650",
                        "title": "Saya mengidentifikasi dan memantau pola relasi yang terjalin dengan pihak terkait di pekerjaan",
                        "score": 1,
                        "questionId": "f92efc6f-d85a-4ba6-a7c2-1782b73dcff9"
                    },
                    {
                        "id": "d7baaba0-775e-4e6f-bb4d-65e6034c318d",
                        "title": "Saya mampu mengevaluasi pola relasi dengan pihak-pihak yang memiliki posisi kunci dan pengambil keputusan di luar organisasi dalam kemitraan yang sudah terjalin",
                        "score": 4,
                        "questionId": "f92efc6f-d85a-4ba6-a7c2-1782b73dcff9"
                    },
                    {
                        "id": "fb76947b-ca1f-46a0-bb82-b5b696a81c4a",
                        "title": "Saya mampu mengidentifikasi adanya peluang bisnis baru dari kerja sama yang telah terjalin",
                        "score": 2,
                        "questionId": "f92efc6f-d85a-4ba6-a7c2-1782b73dcff9"
                    }
                ]
            },
            {
                "id": "f14a4c20-5d37-41ae-8cd6-22087a4bc3de",
                "topic": "Strategic relationship",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "30d15711-32b8-4b02-a268-005165efd32e",
                        "title": "Saya mampu menggalang sejumlah narasumber berskala global untuk menangani permasalahan atau berbagi informasi.",
                        "score": 4,
                        "questionId": "f14a4c20-5d37-41ae-8cd6-22087a4bc3de"
                    },
                    {
                        "id": "4d5795ce-0191-4901-8f6d-f9e751227cc5",
                        "title": "Saya menyadari perlunya menjalin relasi dengan para ahli di bidang pekerjaan saya",
                        "score": 1,
                        "questionId": "f14a4c20-5d37-41ae-8cd6-22087a4bc3de"
                    },
                    {
                        "id": "b2300396-6290-4cff-b325-b3c318ec92b3",
                        "title": "Saya mampu mengidentifikasi keuntungan dari pola relasi yang telah terjalin",
                        "score": 3,
                        "questionId": "f14a4c20-5d37-41ae-8cd6-22087a4bc3de"
                    },
                    {
                        "id": "efdfec2f-3a3b-487e-ad87-988542a344b7",
                        "title": "Ketika saya mengalami kendala dalam pekerjaan, saya bingung harus menghubungi siapa yang dapat membantu saya.",
                        "score": 0,
                        "questionId": "f14a4c20-5d37-41ae-8cd6-22087a4bc3de"
                    },
                    {
                        "id": "fea6728f-fbfe-457b-8926-c932d4ddabe1",
                        "title": "Saya mampu mengembangkan relasi dengan posisi kunci di dalam organisasi",
                        "score": 2,
                        "questionId": "f14a4c20-5d37-41ae-8cd6-22087a4bc3de"
                    }
                ]
            },
            {
                "id": "a03d8f89-4334-4491-890d-691acc656c3c",
                "topic": "Nurturing People",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "2117e4eb-b095-41bf-804f-52f30f503858",
                        "title": "Saya memberikan rekomendasi program pengembangan yang sesuai dengan kemampuan anggota tim  ",
                        "score": 3,
                        "questionId": "a03d8f89-4334-4491-890d-691acc656c3c"
                    },
                    {
                        "id": "786b6791-7f27-4c03-9157-c04d67a1a8bf",
                        "title": "Saya mampu memberi saran dan umpan balik korektif untuk memenuhi tugas saat ini",
                        "score": 1,
                        "questionId": "a03d8f89-4334-4491-890d-691acc656c3c"
                    },
                    {
                        "id": "b574ca92-0c25-47a3-abda-d50efc4e246b",
                        "title": "Saya mampu melakukan coaching mentoring",
                        "score": 4,
                        "questionId": "a03d8f89-4334-4491-890d-691acc656c3c"
                    },
                    {
                        "id": "c8d99a0e-6c5d-47a2-950f-92e2e84ca26a",
                        "title": "Saya menunjukkan inisiatif dalam mengembangkan diri dan peduli terhadap kebutuhan pengembangan anggota timnya",
                        "score": 2,
                        "questionId": "a03d8f89-4334-4491-890d-691acc656c3c"
                    },
                    {
                        "id": "fc072ab4-1c91-4481-82c1-7bc6fd01034d",
                        "title": "Saya sungkan untuk memberikan masukan berupa saran dan masukkan terkait pekerjaan rekan lain",
                        "score": 0,
                        "questionId": "a03d8f89-4334-4491-890d-691acc656c3c"
                    }
                ]
            },
            {
                "id": "84ee7147-bdd9-4f33-bb40-688c57ad641c",
                "topic": "Nurturing People",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "14bf2876-1d9d-4b68-a19f-e519f98034b6",
                        "title": "Saya secara aktif berbagi pengetahuan dengan rekan kerja dan staf",
                        "score": 2,
                        "questionId": "84ee7147-bdd9-4f33-bb40-688c57ad641c"
                    },
                    {
                        "id": "29d90891-9dee-43a0-83dd-8508951b2643",
                        "title": "Saya mampu membangun dialog dengan berbagai pihak untuk program pengembangan SDM",
                        "score": 4,
                        "questionId": "84ee7147-bdd9-4f33-bb40-688c57ad641c"
                    },
                    {
                        "id": "3d477007-ee42-42af-b111-d5b83a9142f5",
                        "title": "Saya menginisiasi program berbagi pengetahuan di unit ",
                        "score": 3,
                        "questionId": "84ee7147-bdd9-4f33-bb40-688c57ad641c"
                    },
                    {
                        "id": "40a6f506-f4f5-40ac-a993-c3e1c8749ff7",
                        "title": "Saya mendengarkan cerita dan masalah dari orang lain, walaupun tidak selalu memberikan solusi ",
                        "score": 1,
                        "questionId": "84ee7147-bdd9-4f33-bb40-688c57ad641c"
                    },
                    {
                        "id": "78bf9236-94b5-46ef-a09b-9e14e163c1c2",
                        "title": "Saya bukanlah pendengar yang baik ketika rekan sedang menceritakan kendalanya dalam bekerja",
                        "score": 0,
                        "questionId": "84ee7147-bdd9-4f33-bb40-688c57ad641c"
                    }
                ]
            },
            {
                "id": "977fbc50-5833-4511-b9df-d6f082c38a8a",
                "topic": "Nurturing People",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "003c5e8f-ead9-4787-81a1-ed9986d3f718",
                        "title": "Saya menjadi role model di organisasi yang mampu menumbuhkan inspirasi anggota organisasi",
                        "score": 4,
                        "questionId": "977fbc50-5833-4511-b9df-d6f082c38a8a"
                    },
                    {
                        "id": "41ba8148-31e7-4689-a3e2-969cd2c108cd",
                        "title": "Saya mengomunikasikan target diri dan tim serta  memberikan dukungan pada rekan kerja pada ruang lingkup pekerjaan",
                        "score": 1,
                        "questionId": "977fbc50-5833-4511-b9df-d6f082c38a8a"
                    },
                    {
                        "id": "9533e91a-28b4-4503-bea9-dcc3472dd869",
                        "title": "Saya memberikan umpan balik yang konsisten mengenai keterampilan teknis anggota tim",
                        "score": 2,
                        "questionId": "977fbc50-5833-4511-b9df-d6f082c38a8a"
                    },
                    {
                        "id": "b46d60a7-36d9-427e-8595-56a5ad52a396",
                        "title": "Saya belum selalu dapat menentukan target pengembangan diri atau tim yang mendukung lingkup pekerjaan saya",
                        "score": 0,
                        "questionId": "977fbc50-5833-4511-b9df-d6f082c38a8a"
                    },
                    {
                        "id": "d7ea2c99-f3da-4f6c-a556-60eb7e32b9aa",
                        "title": "Saya menjalin komunikasi dengan berbagai pihak dengan berbagai media yang ada",
                        "score": 3,
                        "questionId": "977fbc50-5833-4511-b9df-d6f082c38a8a"
                    }
                ]
            },
            {
                "id": "ad113ea9-d020-4830-861d-15930fede88a",
                "topic": "Entrepreneurship",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "137b66ad-0d6b-454d-a987-b2a9f888f517",
                        "title": "Saya mampu menerapkan IT sebagai dasar dalam mengembangkan bisnis",
                        "score": 2,
                        "questionId": "ad113ea9-d020-4830-861d-15930fede88a"
                    },
                    {
                        "id": "465a534d-9449-475a-8bdc-3d39e797109f",
                        "title": "Saya mampu menindaklanjuti peluang bisnis jangka pendek",
                        "score": 1,
                        "questionId": "ad113ea9-d020-4830-861d-15930fede88a"
                    },
                    {
                        "id": "4d6149cd-b607-432f-b3f8-9ffb228cf0a3",
                        "title": "Saya mampu merancang produk/layanan baru dan mengembangkan sistem IT untuk pengembangan strategi bisnis organisasi ",
                        "score": 4,
                        "questionId": "ad113ea9-d020-4830-861d-15930fede88a"
                    },
                    {
                        "id": "a91379fb-eddb-4be7-be47-47ba00ffa52f",
                        "title": "Saya belum melihat adanya peluang bisnis atau upaya efisiensi lagi yang berkaitan dengan pekerjaan saya.",
                        "score": 0,
                        "questionId": "ad113ea9-d020-4830-861d-15930fede88a"
                    },
                    {
                        "id": "beb4ae12-dd5f-47c0-ae2e-7f28b163a525",
                        "title": "Saya mampu memanfaatkan penerapan IT untuk pengembangan bisnis jangka panjang",
                        "score": 3,
                        "questionId": "ad113ea9-d020-4830-861d-15930fede88a"
                    }
                ]
            },
            {
                "id": "45f34670-3690-47b4-89eb-bf735b91a04a",
                "topic": "Entrepreneurship",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "12d4a967-957e-4543-9ee7-e576ca05b8b5",
                        "title": "Saya mampu mengidentifikasi peluang cost leadership ",
                        "score": 2,
                        "questionId": "45f34670-3690-47b4-89eb-bf735b91a04a"
                    },
                    {
                        "id": "2294e27f-b11d-4b0b-a9a6-dd96db1eedcd",
                        "title": "Saya mampu menghitung risiko skala global dan domestik untuk menentukan arah bisnis perusahaan",
                        "score": 4,
                        "questionId": "45f34670-3690-47b4-89eb-bf735b91a04a"
                    },
                    {
                        "id": "481be178-19d2-4440-aa30-81c5fcabc0b1",
                        "title": "Saya meminta tim IT atau anak muda di unit saya untuk menyelesaikan permasalahan yang berhubungan dengan teknologi.",
                        "score": 0,
                        "questionId": "45f34670-3690-47b4-89eb-bf735b91a04a"
                    },
                    {
                        "id": "bbc0d626-53f3-4878-b8de-4cb44aa25bc4",
                        "title": "Saya menggunakan IT untuk menyelesaikan tugas operasional ",
                        "score": 1,
                        "questionId": "45f34670-3690-47b4-89eb-bf735b91a04a"
                    },
                    {
                        "id": "be95aa9e-cc08-4265-9026-ce13672d9218",
                        "title": "Saya mampu mengembangkan cara yang relevan untuk menindaklanjuti peluang bisnis jangka panjang ",
                        "score": 3,
                        "questionId": "45f34670-3690-47b4-89eb-bf735b91a04a"
                    }
                ]
            },
            {
                "id": "c93b3727-a57a-4f15-8995-040e12bb07a4",
                "topic": "Entrepreneurship",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "61485e4a-128e-4740-9d6d-30a8e90e5d9d",
                        "title": "Saya mampu menganalisis faktor-faktor penghambat kinerja unit, serta risiko yang menyertainya",
                        "score": 2,
                        "questionId": "c93b3727-a57a-4f15-8995-040e12bb07a4"
                    },
                    {
                        "id": "9e50e1a2-56e9-42c7-956e-2835064cbb2f",
                        "title": "Saya mengalami kendala dalam menerapkan konsep dalam mengatasi permasalahan organisasi",
                        "score": 0,
                        "questionId": "c93b3727-a57a-4f15-8995-040e12bb07a4"
                    },
                    {
                        "id": "ad2635b5-368a-43af-a4ec-cb6a5c50f7e3",
                        "title": "Saya mampu menganalisis faktor utama penghambat kinerja perusahaan dan kaitannya dengan kebijakan perusahaan, serta mengambil langkah tindakan yang tepat",
                        "score": 4,
                        "questionId": "c93b3727-a57a-4f15-8995-040e12bb07a4"
                    },
                    {
                        "id": "e0c1f0b3-4814-4ad6-bace-8dcb0cd7aeeb",
                        "title": "Saya mampu menggunakan prinsip/teori dasar dalam menganalisis risiko dan mempertimbangkan tindakan di organisasi",
                        "score": 1,
                        "questionId": "c93b3727-a57a-4f15-8995-040e12bb07a4"
                    },
                    {
                        "id": "eb142588-9095-4de4-b7ea-6953df7c576a",
                        "title": "Saya mampu memanfaatkan tren bisnis domestik untuk menetapkan tindakan bisnis bagi perusahaan",
                        "score": 3,
                        "questionId": "c93b3727-a57a-4f15-8995-040e12bb07a4"
                    }
                ]
            }
        ]
    },
{
        "id": "08d8686b-f079-4f72-837c-335c00bb7070",
        "title": "Strategic Management",
        "description": "Strategic Management",
        "htmlContent": "<p>Strategic Management</p>",
        "publishDate": "2020-10-04T20:46:47.759499",
        "startDate": "2020-10-10T00:00:00",
        "endDate": "2021-02-02T00:00:00",
        "totalQuestion": 0,
        "isActive": true,
        "topicId": "e290a015-0592-4e17-8093-cebfa3643728",
        "version": 1,
        "questions": [
            {
                "id": "d94a7efc-e8ea-4d7e-bf0d-44be336bcb3a",
                "title": "Di bawah ini mana pernyataan yang paling cocok dengan keaadan mu?",
                "keyBehaviorId": "c70f3f75-69df-436a-91ba-465a4e18c74d",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "49de2386-ad05-4931-a91a-e80f5bddc435",
                        "title": "saya menerima ide orang lain sebagai masukan berharga",
                        "score": 0,
                        "questionId": "d94a7efc-e8ea-4d7e-bf0d-44be336bcb3a"
                    },
                    {
                        "id": "ecb3f923-b020-4408-9e16-4a9d384c5b4d",
                        "title": "saya memahami suatu persoalan dari sudut pandang lawan bicara saya",
                        "score": 1,
                        "questionId": "d94a7efc-e8ea-4d7e-bf0d-44be336bcb3a"
                    }
                ]
            },
            {
                "id": "070dee32-4e5f-40e5-b787-3eb0b0b8444a",
                "title": "Di bawah ini mana pernyataan yang paling cocok dengan keaadan mu?",
                "keyBehaviorId": "c70f3f75-69df-436a-91ba-465a4e18c74d",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "c2d20fcd-73d2-4d70-8776-dfc28e7a9879",
                        "title": "saya menerima ide orang lain sebagai masukan berharga",
                        "score": 0,
                        "questionId": "070dee32-4e5f-40e5-b787-3eb0b0b8444a"
                    },
                    {
                        "id": "dc8e1342-8ed7-4398-8a30-6db76e13b587",
                        "title": "saya menggunakan sudut pandang yang berbeda dengan perspektif yang biasa saya pakai",
                        "score": 1,
                        "questionId": "070dee32-4e5f-40e5-b787-3eb0b0b8444a"
                    }
                ]
            },
            {
                "id": "ed3bae23-4720-42da-8e3a-b53d1954004e",
                "title": "Di bawah ini mana pernyataan yang paling cocok dengan keaadan mu?",
                "keyBehaviorId": "c70f3f75-69df-436a-91ba-465a4e18c74d",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "32154839-2b5c-42ed-9ddc-9b9b8015def5",
                        "title": "saya memahami suatu persoalan dari sudut pandang lawan bicara saya",
                        "score": 1,
                        "questionId": "ed3bae23-4720-42da-8e3a-b53d1954004e"
                    },
                    {
                        "id": "b8f2221d-fafd-473a-9292-d963ad204211",
                        "title": "saya mendengarkan pendapat orang lain tanpa mengkritik",
                        "score": 0,
                        "questionId": "ed3bae23-4720-42da-8e3a-b53d1954004e"
                    }
                ]
            },
            {
                "id": "c602f9bd-158a-43d7-80f0-bea2402f7a37",
                "title": "Di bawah ini mana pernyataan yang paling cocok dengan keaadan mu?",
                "keyBehaviorId": "c70f3f75-69df-436a-91ba-465a4e18c74d",
                "type": 0,
                "assessmentId": "00000000-0000-0000-0000-000000000000",
                "answers": [
                    {
                        "id": "9aa43d28-8178-4718-8b95-98711113feac",
                        "title": "saya menggunakan sudut pandang yang berbeda dengan perspektif yang biasa saya pakai",
                        "score": 1,
                        "questionId": "c602f9bd-158a-43d7-80f0-bea2402f7a37"
                    },
                    {
                        "id": "aa8517ac-a965-421c-94ce-a10ec7acbab3",
                        "title": "saya mendengarkan pendapat orang lain tanpa mengkritik",
                        "score": 0,
                        "questionId": "c602f9bd-158a-43d7-80f0-bea2402f7a37"
                    }
                ]
            }
        ]
    }
    ]
    """;
    final list = AssessmentModel.fromListJson(jsonDecode(json));
    final model = list.firstWhere((element) => element.id == id);
    return createResponse(
      model,
    );
  }

  //   @override
  //   FutureOr<BaseResponse<PodcastDetailItem>> getDetailPodcast(String id, {CancelToken cancelToken}) {
  //     // TODO: implement getDetailPodcast
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<SeriesDetailItem>> getDetailSeries(String id, {CancelToken cancelToken}) {
  //     // TODO: implement getDetailSeries
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<VideoDetailItem>> getDetailVideo(String id, {CancelToken cancelToken}) {
  //     // TODO: implement getDetailVideo
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<GoalItem>> getGoal(String id, {CancelToken cancelToken}) {
  //     // TODO: implement getGoal
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<List<GoalItem>>> getGoals({CancelToken cancelToken}) {
  //     // TODO: implement getGoals
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<List<UserActivityResponse>>> getLastActivity(GetLastActivityRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement getLastActivity
  //     throw UnimplementedError();
  //   }

  // @override
  // FutureOr<BaseResponse<List<AuthorModel>>> getListAuthor(
  //     {int page, int pageSize, String query, CancelToken cancelToken}) {
  //   return createResponse(List<AuthorModel>.from([
  //     AuthorModel()
  //       ..id = _uuid.v4()
  //       ..name = 'Author name',
  //   ]));
  // }

  // @override
  // FutureOr<BaseResponse<List<InterestModel>>> getMyInterest(
  //     {CancelToken cancelToken}) {
  //   return createResponse(
  //     List<InterestModel>()
  //       ..add(
  //         InterestModel()..name = 'Intereset ${_uuid.v4()}',
  //       ),
  //   );
  // }

  //   @override
  //   FutureOr<BaseResponse<List<ActivityItem>>> getOnGoingActivity(GetActivityRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement getOnGoingActivity
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<List<RecentSessionModel>>> getRecentSession(GetRecentSessionRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement getRecentSession
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<List<BrowseModel>>> getRecommendationByAssessment({GetBrowseRequest request, CancelToken cancelToken}) {
  //     // TODO: implement getRecommendationByAssessment
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<List<BrowseModel>>> getRecommendationByInterest({GetBrowseRequest request, CancelToken cancelToken}) {
  //     // TODO: implement getRecommendationByInterest
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<List<BrowseModel>>> getSearchPopular({GetBrowseRequest request, CancelToken cancelToken}) {
  //     // TODO: implement getSearchPopular
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<TodoItem>> getTodo(String todoId, {CancelToken cancelToken}) {
  //     // TODO: implement getTodo
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<BaseResponse<List<TodoItem>>> getTodoAgenda(GetAgendaRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement getTodoAgenda
  //     throw UnimplementedError();
  //   }

  // @override
  // FutureOr<BaseResponse<List<TopicItem>>> getTopic(GetTopicRequest request,
  //     {CancelToken cancelToken}) {
  //   return createResponse(
  //     List<TopicItem>.from(
  //       [
  //         for (var i = 0; i < 100; i++)
  //           TopicItem()
  //             ..id = _uuid.v4()
  //             ..name = 'Name Name Name Name Name $i'
  //             ..color = i % 2 == 0 ? '#00ff00' : '#0000ff',
  //       ],
  //     ),
  //   );
  // }

  // @override
  // FutureOr<BaseResponse<List<MyAssessmentModel>>> getUserAssessment(
  //     {CancelToken cancelToken}) {
  //   return createResponse(
  //     List<MyAssessmentModel>()
  //       ..add(
  //         MyAssessmentModel()..topic = 'Topic ${_uuid.v4()}',
  //       ),
  //   );
  // }

  //   @override
  //   FutureOr<BaseResponse<UserProfile>> getUserProfile({CancelToken cancelToken}) {
  //     // TODO: implement getUserProfile
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<Response> registerUser(RegisterUserRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement registerUser
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<Response> removeInterest(UserInterestRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement removeInterest
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<Response> saveInterest(UserInterestRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement saveInterest
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<Response> setActivityCompleted(SetCompleteActivityRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement setActivityCompleted
  //     throw UnimplementedError();
  //   }

  //   @override
  //   FutureOr<Response> submitAssessment(SubmitAssessmentRequest request, {CancelToken cancelToken}) {
  //     // TODO: implement submitAssessment
  //     throw UnimplementedError();
  //   }

  // @override
  // FutureOr<Response> updateFcmToken(
  //   String fcmToken, {
  //   CancelToken cancelToken,
  // }) {
  //   return Response()..statusCode = 200;
  // }

  // FutureOr<BaseResponse<List<FaqModel>>> getFaqs({
  //   CancelToken cancelToken,
  // }) {
  //   final List<FaqModel> faqs = [
  //     for (var i = 0; i < 32; i++)
  //       FaqModel()
  //         ..id = i.toString()
  //         ..question =
  //             '$i Question Question Question Question Question Question Question Question Question'
  //         ..answer =
  //             '$i Answer Answer Answer Answer Answer Answer Answer Answer Answer Answer Answer Answer Answer Answer Answer'
  //   ];
  //   final value = createResponse(faqs);
  //   return value;
  // }

  // FutureOr<BaseResponse<List<BrowseModel>>> getRelatedContent(
  //   String id, {
  //   CancelToken cancelToken,
  // }) async {
  //   final request = GetBrowseRequest()
  //     ..page = 1
  //     ..pageLimit = 10
  //     ..query = '';
  //   return getSearchPopular(
  //     request: request,
  //   );
  // }

  // FutureOr<BaseResponse<List<TermConditionModel>>> getPrivacyPolicy({
  //   CancelToken cancelToken,
  // }) async {
  //   return createResponse([
  //     TermConditionModel()
  //       ..id = 'd54b753d-4217-446c-a0fd-1d0aa4cb5642'
  //       ..title = 'About Us'
  //       ..content = '<div>Content Content Content Content Content</div>',
  //   ]);
  // }
}
