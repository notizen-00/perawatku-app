import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/partner_location.dart';

/// Marker dengan icon yang lebih baik untuk flutter_map
Marker createPartnerMarker({
  required PartnerLocation location,
  required VoidCallback? onTap,
}) {
  final color = location.partnerType == PartnerType.doctor
      ? const Color(0xFF2196F3) // Brighter blue
      : const Color(0xFF4CAF50); // Brighter green

  return Marker(
    point: LatLng(location.latitude, location.longitude),
    width: 44,
    height: 44,
    child: GestureDetector(
      onTap: onTap,
      child: _buildMarkerWidget(location, color),
    ),
  );
}

Widget _buildMarkerWidget(PartnerLocation location, Color color) {
  return Container(
    width: 44,
    height: 44,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Shadow
        Positioned(
          top: 2,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Main marker circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            location.partnerType == PartnerType.doctor
                ? Icons.medical_services
                : Icons.local_hospital,
            color: Colors.white,
            size: 20,
          ),
        ),
        // Online indicator
        if (location.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Cluster marker builder
Widget buildClusterMarker(BuildContext context, List<Marker> markers) {
  return Container(
    width: 45,
    height: 45,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Center(
      child: Text(
        '${markers.length}',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}
