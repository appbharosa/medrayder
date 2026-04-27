
import '../../config/routes/app_url.dart';
import '../../model/subscription_model/subscription_model.dart';
import '../../network/dio_network/dio_client.dart';

class SubscriptionsRepository {
  final DioClient dioClient;

  SubscriptionsRepository(this.dioClient);

  Future<SubscriptionResponse> getSubscriptions({
    int? page,
    int? perPage,
  }) async {
    // Build query parameters dynamically
    final queryParams = <String, String>{};

    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    // Build URL with query string
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final url = queryString.isEmpty
        ? AppUrl.subscription
        : "${AppUrl.subscription}?$queryString";

    final response = await dioClient.get(url);

    ///  SAFE CHECK
    if (response == null) {
      throw Exception("No response from server");
    }
    ///  HANDLE STATUS SAFELY
    if (response["status"] == 200) {
      return SubscriptionResponse.fromJson(response);
    } else {
      throw Exception(response["message"] ?? "Something went wrong");
    }
  }
}