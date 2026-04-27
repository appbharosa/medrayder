
import '../../config/routes/app_url.dart';
import '../../model/update_response/update_response.dart';
import '../../network/dio_network/dio_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateRepository {
  final DioClient dioClient;

  UpdateRepository(this.dioClient);

  Future<UpdateResponse> getUpdateApi() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    // 👈 Fix the URL construction
    final response = await dioClient.get(
      "${AppUrl.updateApi}?version=$version", // Changed = to ?version=
    );

    if (response == null) {
      throw Exception("No response from server");
    }

    return UpdateResponse.fromJson(response);
  }
}