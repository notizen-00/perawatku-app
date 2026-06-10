import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/partner_location.dart';
import '../controllers/map_controller.dart' as map_controller;

/// Membuat marker untuk lokasi mitra
Marker createPartnerMarker({
  required PartnerLocation location,
  required map_controller.MapController controller,
}) {
  return Marker(
    width: 40,
    height: 40,
    point: LatLng(location.latitude, location.longitude),
    child: GestureDetector(
      onTap: () {
        controller.moveToLocation(
          LatLng(location.latitude, location.longitude),
          zoom: 16,
        );
        _showPartnerInfo(location);
      },
      child: _buildMarkerWidget(location),
    ),
  );
}

Widget _buildMarkerWidget(PartnerLocation location) {
  final color = location.partnerType == PartnerType.doctor
      ? Colors.blue
      : Colors.green;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Icon(
            location.partnerType == PartnerType.doctor
                ? Icons.medical_services
                : Icons.local_hospital,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      if (location.isOnline)
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Online',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  );
}

void _showPartnerInfo(PartnerLocation location) {
  // Simple snackbar for now - can be enhanced with a custom dialog
  Get.snackbar(
    location.name,
    '${location.partnerType.displayName}\n${location.address ?? "Lokasi tidak tersedia"}',
    duration: const Duration(seconds: 3),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.black87,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
  );
}
