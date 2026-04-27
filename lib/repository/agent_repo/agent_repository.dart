
import '../../config/routes/app_url.dart';
import '../../model/agent_model/agent_model.dart';
import '../../network/dio_network/dio_client.dart';

class AgentRepository {
  final DioClient dioClient;

  AgentRepository(this.dioClient);

  Future<AgentPagination> getAgents({
    int page = 1,
    int? perPage,
    String? search,
  }) async {

    /// ✅ BUILD URL DYNAMICALLY
    final url =
        "${AppUrl.getAgents}?page=$page"
        "${perPage != null ? "&per_page=$perPage" : ""}"
        "${(search != null && search.isNotEmpty) ? "&search=$search" : ""}";

    final response = await dioClient.get(url);

    if (response["status"] == 200) {

      /// ⚠️ SAFE PARSING
      final result = response["result"];

      if (result is List && result.isNotEmpty) {
        return AgentPagination.fromJson(result[0]);
      } else {
        throw Exception("Invalid response format");
      }

    } else {
      throw Exception(response["message"]);
    }
  }
}