import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/helpers/app_snackbar.dart';
import '../../domain/entities/patient_member_entity.dart';
import '../../domain/entities/patient_member_payload.dart';
import '../../domain/usecases/delete_patient_member_use_case.dart';
import '../../domain/usecases/get_patient_members_use_case.dart';
import '../../domain/usecases/save_patient_member_use_case.dart';
import '../../domain/usecases/set_primary_patient_member_use_case.dart';

class PatientMemberController extends GetxController {
  PatientMemberController({
    required GetPatientMembersUseCase getMembersUseCase,
    required SavePatientMemberUseCase saveMemberUseCase,
    required SetPrimaryPatientMemberUseCase setPrimaryUseCase,
    required DeletePatientMemberUseCase deleteMemberUseCase,
  }) : _getMembersUseCase = getMembersUseCase,
       _saveMemberUseCase = saveMemberUseCase,
       _setPrimaryUseCase = setPrimaryUseCase,
       _deleteMemberUseCase = deleteMemberUseCase;

  final GetPatientMembersUseCase _getMembersUseCase;
  final SavePatientMemberUseCase _saveMemberUseCase;
  final SetPrimaryPatientMemberUseCase _setPrimaryUseCase;
  final DeletePatientMemberUseCase _deleteMemberUseCase;

  final RxList<PatientMemberEntity> members = <PatientMemberEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<PatientMemberEntity> editingMember = Rxn<PatientMemberEntity>();
  final RxString selectedRelationship = ''.obs;

  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final relationshipController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final phoneController = TextEditingController();
  final bloodTypeController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyContactPhoneController = TextEditingController();
  final allergiesController = TextEditingController();
  final medicalNotesController = TextEditingController();
  final addressLabelController = TextEditingController();
  final recipientNameController = TextEditingController();
  final recipientPhoneController = TextEditingController();
  final addressController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final postalCodeController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final RxBool isPrimaryForm = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    relationshipController.dispose();
    dateOfBirthController.dispose();
    ageController.dispose();
    genderController.dispose();
    phoneController.dispose();
    bloodTypeController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactPhoneController.dispose();
    allergiesController.dispose();
    medicalNotesController.dispose();
    addressLabelController.dispose();
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    addressController.dispose();
    provinceController.dispose();
    cityController.dispose();
    districtController.dispose();
    postalCodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  Future<void> loadMembers() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _getMembersUseCase(
        relationship: selectedRelationship.value,
        search: searchController.text,
        perPage: 100,
      );
      members.assignAll(result);
    } on AppException catch (error) {
      members.clear();
      errorMessage.value = error.message;
    } catch (_) {
      members.clear();
      errorMessage.value = 'Gagal memuat profil pasien keluarga.';
    } finally {
      isLoading.value = false;
    }
  }

  void applyRelationshipFilter(String relationship) {
    selectedRelationship.value = relationship;
    loadMembers();
  }

  void startCreate() {
    editingMember.value = null;
    _clearForm();
  }

  void startEdit(PatientMemberEntity member) {
    editingMember.value = member;
    nameController.text = member.name;
    relationshipController.text = member.relationship;
    dateOfBirthController.text = member.dateOfBirth;
    ageController.text = member.age?.toString() ?? '';
    genderController.text = member.gender;
    phoneController.text = member.phone;
    bloodTypeController.text = member.bloodType;
    emergencyContactNameController.text = member.emergencyContactName;
    emergencyContactPhoneController.text = member.emergencyContactPhone;
    allergiesController.text = member.allergies;
    medicalNotesController.text = member.medicalNotes;
    addressLabelController.text = member.addressLabel;
    recipientNameController.text = member.recipientName;
    recipientPhoneController.text = member.recipientPhone;
    addressController.text = member.address;
    provinceController.text = member.province;
    cityController.text = member.city;
    districtController.text = member.district;
    postalCodeController.text = member.postalCode;
    latitudeController.text = member.latitude?.toString() ?? '';
    longitudeController.text = member.longitude?.toString() ?? '';
    isPrimaryForm.value = member.isPrimary;
  }

  void setDateOfBirth(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    dateOfBirthController.text = '$year-$month-$day';
  }

  void setGender(String? gender) {
    genderController.text = gender ?? '';
  }

  void setRelationship(String? relationship) {
    relationshipController.text = relationship ?? '';
  }

  void setCoordinates({
    required double latitude,
    required double longitude,
  }) {
    latitudeController.text = latitude.toStringAsFixed(6);
    longitudeController.text = longitude.toStringAsFixed(6);
  }

  Future<bool> saveMember() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppSnackbar.info('Nama wajib diisi', 'Isi nama profil pasien dulu.');
      return false;
    }

    final age = _parseOptionalInt(ageController.text);
    if (ageController.text.trim().isNotEmpty && age == null) {
      AppSnackbar.info('Umur tidak valid', 'Isi umur dengan angka 0 sampai 150.');
      return false;
    }

    final latitude = _parseOptionalDouble(latitudeController.text);
    final longitude = _parseOptionalDouble(longitudeController.text);
    if ((latitudeController.text.trim().isNotEmpty && latitude == null) ||
        (longitudeController.text.trim().isNotEmpty && longitude == null)) {
      AppSnackbar.info('Koordinat tidak valid', 'Isi latitude dan longitude dengan angka.');
      return false;
    }

    isSaving.value = true;

    try {
      final payload = PatientMemberPayload(
        name: name,
        relationship: relationshipController.text,
        dateOfBirth: dateOfBirthController.text,
        age: age,
        gender: genderController.text,
        phone: phoneController.text,
        bloodType: bloodTypeController.text,
        emergencyContactName: emergencyContactNameController.text,
        emergencyContactPhone: emergencyContactPhoneController.text,
        allergies: allergiesController.text,
        medicalNotes: medicalNotesController.text,
        addressLabel: addressLabelController.text,
        recipientName: recipientNameController.text,
        recipientPhone: recipientPhoneController.text,
        address: addressController.text,
        province: provinceController.text,
        city: cityController.text,
        district: districtController.text,
        postalCode: postalCodeController.text,
        latitude: latitude,
        longitude: longitude,
        isPrimary: isPrimaryForm.value,
      );

      await _saveMemberUseCase(
        memberId: editingMember.value?.id,
        payload: payload,
      );
      await loadMembers();

      return true;
    } on AppException catch (error) {
      AppSnackbar.error('Simpan gagal', error.message);
      return false;
    } catch (_) {
      AppSnackbar.error('Simpan gagal', 'Profil pasien belum bisa disimpan.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> setPrimary(PatientMemberEntity member) async {
    if (member.isPrimary) {
      return;
    }

    try {
      await _setPrimaryUseCase(member.id);
      await loadMembers();
      AppSnackbar.success('Profil utama aktif', '${member.name} menjadi profil utama.');
    } on AppException catch (error) {
      AppSnackbar.error('Gagal mengubah profil utama', error.message);
    } catch (_) {
      AppSnackbar.error('Gagal mengubah profil utama', 'Silakan coba lagi nanti.');
    }
  }

  Future<void> deleteMember(PatientMemberEntity member) async {
    isDeleting.value = true;

    try {
      await _deleteMemberUseCase(member.id);
      await loadMembers();
      AppSnackbar.success('Profil dihapus', '${member.name} sudah dihapus.');
    } on AppException catch (error) {
      AppSnackbar.error('Hapus gagal', error.message);
    } catch (_) {
      AppSnackbar.error('Hapus gagal', 'Profil pasien belum bisa dihapus.');
    } finally {
      isDeleting.value = false;
    }
  }

  void _clearForm() {
    nameController.clear();
    relationshipController.clear();
    dateOfBirthController.clear();
    ageController.clear();
    genderController.clear();
    phoneController.clear();
    bloodTypeController.clear();
    emergencyContactNameController.clear();
    emergencyContactPhoneController.clear();
    allergiesController.clear();
    medicalNotesController.clear();
    addressLabelController.clear();
    recipientNameController.clear();
    recipientPhoneController.clear();
    addressController.clear();
    provinceController.clear();
    cityController.clear();
    districtController.clear();
    postalCodeController.clear();
    latitudeController.clear();
    longitudeController.clear();
    isPrimaryForm.value = members.isEmpty;
  }

  int? _parseOptionalInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0 || parsed > 150) return null;
    return parsed;
  }

  double? _parseOptionalDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }
}
