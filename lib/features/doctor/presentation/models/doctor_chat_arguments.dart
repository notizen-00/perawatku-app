import '../../domain/entities/doctor_entity.dart';

class DoctorChatArguments {
  const DoctorChatArguments({
    this.doctor,
    this.consultationId,
    this.doctorName,
    this.specialization,
    this.partnerUserId,
    this.doctorPhotoUrl,
  });

  final DoctorEntity? doctor;
  final int? consultationId;
  final String? doctorName;
  final String? specialization;
  final int? partnerUserId;
  final String? doctorPhotoUrl;
}
