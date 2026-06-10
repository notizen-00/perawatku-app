import 'package:latlong2/latlong.dart';

class NavigationRoute {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  const NavigationRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  bool get hasGeometry => points.length >= 2;
}
