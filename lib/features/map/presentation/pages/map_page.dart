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
          Obx(() {
            if (controller.isLoading.value &&
                controller.partnerLocations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return FlutterMap(
              mapController: controller.flutterMapController,
              options: MapOptions(
                initialCenter: controller.mapCenter.value,
                initialZoom: controller.mapZoom.value,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.medic.patient.app',
                  maxZoom: 19,
                ),
                if (controller.routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: controller.routePoints.toList(),
                        strokeWidth: 5,
                        color: AppColors.primary,
                        borderStrokeWidth: 2,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    markers: controller.filteredLocations
                        .map(
                          (location) => createPartnerMarker(
                            location: location,
                            onTap: () => _showPartnerInfo(context, location),
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
                    onSelected: (_) => controller.setFilter(null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Dokter'),
                    selected: controller.filterType.value == PartnerType.doctor,
                    onSelected: (_) =>
                        controller.toggleFilter(PartnerType.doctor),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Perawat'),
                    selected: controller.filterType.value == PartnerType.nurse,
                    onSelected: (_) =>
                        controller.toggleFilter(PartnerType.nurse),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Obx(() => _buildBottomPanel(context, controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, MapController controller) {
    final selectedPartner = controller.selectedPartner.value;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: selectedPartner == null
            ? _buildNearestPartnersPanel(context, controller)
            : _buildNavigationPanel(context, controller, selectedPartner),
      ),
    );
  }

  Widget _buildNearestPartnersPanel(
    BuildContext context,
    MapController controller,
  ) {
    final nearestPartners = controller.getNearestPartners(count: 3);

    return Column(
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
        if (nearestPartners.isEmpty)
          Text(
            'Belum ada mitra tersedia',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...nearestPartners.map(
            (partner) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _buildPartnerAvatar(partner),
              title: Text(partner.name, style: const TextStyle(fontSize: 14)),
              subtitle: Text(
                '${partner.partnerType.displayName} - ${_calculateDistance(controller, partner)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.navigation),
                color: AppColors.primary,
                tooltip: 'Lacak perjalanan',
                onPressed: () => controller.startNavigation(partner),
              ),
              onTap: () => controller.startNavigation(partner),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationPanel(
    BuildContext context,
    MapController controller,
    PartnerLocation partner,
  ) {
    final progressPercent = (controller.partnerProgress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildPartnerAvatar(partner),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${partner.partnerType.displayName} - update ${controller.lastPartnerUpdateLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Stop tracking',
              onPressed: controller.stopNavigation,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.isRouteLoading.value)
          const LinearProgressIndicator(minHeight: 3)
        else
          LinearProgressIndicator(
            value: controller.partnerProgress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary,
            backgroundColor: AppColors.lightBorder,
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetric(
              context,
              icon: Icons.schedule,
              label: 'ETA',
              value: controller.etaLabel,
            ),
            _buildMetric(
              context,
              icon: Icons.route,
              label: 'Sisa rute',
              value: controller.routeDistanceLabel,
            ),
            _buildMetric(
              context,
              icon: Icons.trending_up,
              label: 'Progress',
              value: '$progressPercent%',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.moveToLocation(
                  LatLng(partner.latitude, partner.longitude),
                  zoom: 16,
                ),
                icon: const Icon(Icons.person_pin_circle),
                label: const Text('Mitra'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => controller.refreshNavigationRoute(),
                icon: const Icon(Icons.refresh),
                label: const Text('Update'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPartnerAvatar(PartnerLocation partner) {
    return CircleAvatar(
      backgroundColor: partner.partnerType == PartnerType.doctor
          ? Colors.blue
          : Colors.green,
      child: Icon(
        partner.partnerType == PartnerType.doctor
            ? Icons.medical_services
            : Icons.local_hospital,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
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

  void _showPartnerInfo(BuildContext context, PartnerLocation location) {
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
}
