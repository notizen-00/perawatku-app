import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/response_extractors.dart';
import '../models/service_booking_model.dart';
import '../models/service_booking_service_model.dart';

abstract class ServiceBookingRemoteDataSource {
  Future<List<ServiceBookingServiceModel>> getServices({
    int? categoryId,
    String? category,
    String? search,
    int? perPage,
  });

  Future<ServiceBookingModel> createBooking({
    required int serviceId,
    int? patientMemberId,
    int? patientAddressId,
    String? scheduledAt,
    String? visitPlan,
    String? recurrence,
    int? visitCount,
    String? careMode,
    String? locationType,
    String? notes,
    String? promoCode,
  });

  Future<Map<String, dynamic>> checkPromoCode({
    required String code,
    required int serviceId,
  });

  Future<ServiceBookingModel> getBooking(int bookingId);

  Future<ServiceBookingModel> payBooking(int bookingId, {String? notes});

  Future<ServiceBookingModel> rematchBooking(int bookingId, {String? notes});

  Future<ServiceBookingModel> confirmCompletion(int bookingId, {String? notes});

  Future<ServiceBookingModel> cancelBooking(int bookingId, {String? reason});
}

class ServiceBookingRemoteDataSourceImpl
    implements ServiceBookingRemoteDataSource {
  ServiceBookingRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ServiceBookingServiceModel>> getServices({
    int? categoryId,
    String? category,
    String? search,
    int? perPage,
  }) async {
    final response = await _apiClient.get(
      AppEndpoints.patientServiceBookingServices,
      queryParameters: <String, dynamic>{
        if (categoryId != null && categoryId > 0) 'category_id': categoryId,
        if ((categoryId == null || categoryId <= 0) &&
            category != null &&
            category.trim().isNotEmpty)
          'category': category.trim(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (perPage != null) 'per_page': perPage,
      },
    );

    final items = extractLaravelPaginatedList(response);
    return items.map(ServiceBookingServiceModel.fromJson).toList();
  }

  @override
  Future<ServiceBookingModel> createBooking({
    required int serviceId,
    int? patientMemberId,
    int? patientAddressId,
    String? scheduledAt,
    String? visitPlan,
    String? recurrence,
    int? visitCount,
    String? careMode,
    String? locationType,
    String? notes,
    String? promoCode,
  }) async {
    final response = await _apiClient.post(
      AppEndpoints.patientServiceBookings,
      data: <String, dynamic>{
        'service_id': serviceId,
        if (patientMemberId != null) 'patient_member_id': patientMemberId,
        if (patientAddressId != null) 'patient_address_id': patientAddressId,
        if (scheduledAt != null && scheduledAt.trim().isNotEmpty)
          'scheduled_at': scheduledAt.trim(),
        if (visitPlan != null && visitPlan.trim().isNotEmpty)
          'visit_plan': visitPlan.trim(),
        if (recurrence != null && recurrence.trim().isNotEmpty)
          'recurrence': recurrence.trim(),
        if (visitCount != null) 'visit_count': visitCount,
        if (careMode != null && careMode.trim().isNotEmpty)
          'care_mode': careMode.trim(),
        if (locationType != null && locationType.trim().isNotEmpty)
          'location_type': locationType.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (promoCode != null && promoCode.trim().isNotEmpty)
          'promo_code': promoCode.trim(),
      },
    );

    return ServiceBookingModel.fromJson(response);
  }

  @override
  Future<Map<String, dynamic>> checkPromoCode({
    required String code,
    required int serviceId,
  }) {
    return _apiClient.post(
      AppEndpoints.patientServiceBookingCheckPromoCode,
      data: <String, dynamic>{'code': code.trim(), 'service_id': serviceId},
    );
  }

  @override
  Future<ServiceBookingModel> getBooking(int bookingId) async {
    final endpoint = '${AppEndpoints.patientServiceBookings}/$bookingId';
    debugPrint(
      '[matchmaking-rematch] API GET start endpoint=$endpoint '
      'bookingId=$bookingId',
    );
    final response = await _apiClient.get(
      endpoint,
    );
    debugPrint(
      '[matchmaking-rematch] API GET response bookingId=$bookingId '
      'raw=${jsonEncode(response)}',
    );

    return ServiceBookingModel.fromJson(response);
  }

  @override
  Future<ServiceBookingModel> payBooking(int bookingId, {String? notes}) async {
    final trimmedNotes = notes?.trim();
    final response = await _apiClient.patch(
      '${AppEndpoints.patientServiceBookings}/$bookingId/pay',
      data: <String, dynamic>{
        if (trimmedNotes != null && trimmedNotes.isNotEmpty)
          'notes': trimmedNotes,
      },
    );

    return ServiceBookingModel.fromJson(response);
  }

  @override
  Future<ServiceBookingModel> rematchBooking(
    int bookingId, {
    String? notes,
  }) async {
    final trimmedNotes = notes?.trim();
    final endpoint = '${AppEndpoints.patientServiceBookings}/$bookingId/rematch';
    debugPrint(
      '[matchmaking-rematch] API POST start endpoint=$endpoint '
      'bookingId=$bookingId notes="${trimmedNotes ?? ''}"',
    );
    final response = await _apiClient.post(
      endpoint,
      data: <String, dynamic>{
        if (trimmedNotes != null && trimmedNotes.isNotEmpty)
          'notes': trimmedNotes,
      },
    );
    debugPrint(
      '[matchmaking-rematch] API POST response bookingId=$bookingId '
      'raw=${jsonEncode(response)}',
    );

    return ServiceBookingModel.fromJson(response);
  }

  @override
  Future<ServiceBookingModel> confirmCompletion(
    int bookingId, {
    String? notes,
  }) async {
    final trimmedNotes = notes?.trim();
    final response = await _apiClient.patch(
      '${AppEndpoints.patientServiceBookings}/$bookingId/confirm-completion',
      data: <String, dynamic>{
        if (trimmedNotes != null && trimmedNotes.isNotEmpty)
          'notes': trimmedNotes,
      },
    );

    return ServiceBookingModel.fromJson(response);
  }

  @override
  Future<ServiceBookingModel> cancelBooking(
    int bookingId, {
    String? reason,
  }) async {
    final trimmedReason = reason?.trim();
    final response = await _apiClient.patch(
      '${AppEndpoints.patientServiceBookings}/$bookingId/cancel',
      data: <String, dynamic>{
        if (trimmedReason != null && trimmedReason.isNotEmpty)
          'notes': trimmedReason,
      },
    );

    return ServiceBookingModel.fromJson(response);
  }
}
