import 'package:get/get.dart';

import '../../../../core/services/midtrans_service.dart';
import '../../../../core/services/reverb_websocket_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../consultation/domain/usecases/create_consultation_use_case.dart';
import '../../../consultation/domain/usecases/get_consultation_use_case.dart';
import '../../../consultation/domain/usecases/pay_consultation_use_case.dart';
import '../../../consultation/domain/usecases/send_consultation_message_use_case.dart';
import '../controllers/doctor_chat_controller.dart';

class DoctorChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorChatController>(
      () => DoctorChatController(
        createConsultationUseCase: Get.find<CreateConsultationUseCase>(),
        getConsultationUseCase: Get.find<GetConsultationUseCase>(),
        payConsultationUseCase: Get.find<PayConsultationUseCase>(),
        sendConsultationMessageUseCase:
            Get.find<SendConsultationMessageUseCase>(),
        midtransService: Get.find<MidtransService>(),
        storageService: Get.find<StorageService>(),
        reverbWebSocketService: Get.find<ReverbWebSocketService>(),
      ),
    );
  }
}
