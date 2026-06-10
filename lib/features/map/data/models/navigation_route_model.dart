import 'package:latlong2/latlong.dart';

import '../../domain/entities/navigation_route.dart';

class NavigationRouteModel extends NavigationRoute {
  const NavigationRouteModel({
    required super.points,
    required super.distanceMeters,
    required super.durationSeconds,
  });

  factory NavigationRouteModel.fromOsrmJson(Map<String, dynamic> json) {
    final routes = json['routes'];
    if (routes is! List || routes.isEmpty || routes.first is! Map) {
      throw const FormatException('Rute tidak ditemukan');
    }

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'];
    final coordinates = geometry is Map<String, dynamic>
        ? geometry['coordinates']
        : null;

    final points = <LatLng>[];
    if (coordinates is List) {
      for (final coordinate in coordinates) {
        if (coordinate is List && coordinate.length >= 2) {
          final longitude = (coordinate[0] as num).toDouble();
          final latitude = (coordinate[1] as num).toDouble();
          points.add(LatLng(latitude, longitude));
        }
      }
    }

    return NavigationRouteModel(
      points: points,
      distanceMeters: ((route['distance'] ?? 0) as num).toDouble(),
      durationSeconds: ((route['duration'] ?? 0) as num).toDouble(),
    );
  }
}
