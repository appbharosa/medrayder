
import '../../config/routes/app_url.dart';
import '../../model/user_model/user_model.dart';
import '../../network/dio_network/dio_client.dart';

class UserRepository {
  final DioClient dioClient;
  UserRepository(this.dioClient);

  Future<PaginatedUserResponse> getUsers({
    int page = 1,
    int? perPage,
    String? search,
  }) async {



    final response = await dioClient.get(
      "${AppUrl.getUsers}?page=$page"
          "${perPage != null ? "&per_page=$perPage" : ""}"
          "${search != null ? "&search=$search" : ""}",
    );
    if (response["status"] == 200) {
      return PaginatedUserResponse.fromJson(response);
    } else {
      throw Exception(response["message"]);
    }
  }
}