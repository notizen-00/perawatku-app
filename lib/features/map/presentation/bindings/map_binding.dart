import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/datasources/map_remote_data_source.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_partner_locations_use_case.dart';
import '../controllers/map_controller.dart';

/// Binding untuk feature map
class MapBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<MapRemoteDataSource>(
      () => MapRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    // Repository
    Get.lazyPut<MapRepository>(
      () =>
          MapRepositoryImpl(remoteDataSource: Get.find<MapRemoteDataSource>()),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut<GetPartnerLocationsUseCase>(
      () => GetPartnerLocationsUseCase(Get.find<MapRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetNavigationRouteUseCase>(
      () => GetNavigationRouteUseCase(Get.find<MapRepository>()),
      fenix: true,
    );

    // Controller
    Get.put(
      MapController(
        Get.find<GetPartnerLocationsUseCase>(),
        Get.find<GetNavigationRouteUseCase>(),
      ),
      permanent: false,
    );
  }
}
