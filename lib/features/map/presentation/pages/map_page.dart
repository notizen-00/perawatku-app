import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/partner_location.dart';
import '../controllers/map_controller.dart';
import '../widgets/partner_marker.dart';

/// Halaman peta untuk menampilkan lokasi mitra (dokter & perawat)
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MapController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Mitra Terdekat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => controller.moveToUserLocation(),
            tooltip: 'Lokasi Saya',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map widget
          Obx(() {
            if (controller.isLoading.value &&
                controller.partnerLocations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return FlutterMap(
              options: MapOptions(
                initialCenter: controller.mapCenter.value,
                initialZoom: controller.mapZoom.value,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Tile layer (OpenStreetMap - free)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.medic.patient.app',
                  maxZoom: 19,
                ),
                // Marker cluster layer
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    markers: controller.filteredLocations
                        .map(
                          (location) => createPartnerMarker(
                            location: location,
                            controller: controller,
                          ),
                        )
                        .toList(),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.primary,
                        ),
                        child: Center(
                          child: Text(
                            '${markers.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // User location marker
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 30,
                      height: 30,
                      point: controller.currentLocation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          width: 12,
                          height: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),

          // Filter chips
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Obx(
              () => Row(
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: controller.filterType.value == null,
                    onSelected: (selected) {
                      controller.setFilter(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Dokter'),
                    selected: controller.filterType.value == PartnerType.doctor,
                    onSelected: (selected) {
                      controller.toggleFilter(PartnerType.doctor);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Perawat'),
                    selected: controller.filterType.value == PartnerType.nurse,
                    onSelected: (selected) {
                      controller.toggleFilter(PartnerType.nurse);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom info card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Obx(
              () => Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mitra Terdekat',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${controller.filteredLocations.length} lokasi',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (controller.filteredLocations.isNotEmpty)
                        ...controller
                            .getNearestPartners(count: 3)
                            .map(
                              (partner) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      partner.partnerType == PartnerType.doctor
                                      ? Colors.blue
                                      : Colors.green,
                                  child: Icon(
                                    partner.partnerType == PartnerType.doctor
                                        ? Icons.medical_services
                                        : Icons.local_hospital,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                title: Text(
                                  partner.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${partner.partnerType.displayName} • ${_calculateDistance(controller, partner)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                onTap: () {
                                  controller.moveToLocation(
                                    LatLng(partner.latitude, partner.longitude),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDistance(MapController controller, PartnerLocation partner) {
    final distance = controller.calculateDistance(
      controller.currentLocation.value,
      LatLng(partner.latitude, partner.longitude),
    );
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }
}
