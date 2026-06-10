# Map Feature Documentation

Dokumentasi untuk fitur peta lokasi mitra (dokter & perawat) pada Medic Patient App.

## 📋 Overview

Fitur peta memungkinkan pasien untuk melihat lokasi dokter dan perawat terdekat secara real-time menggunakan **OpenStreetMap** (gratis, tanpa API key).

### Tech Stack

| Package                      | Version | Purpose                               |
| ---------------------------- | ------- | ------------------------------------- |
| `flutter_map`                | ^7.0.2  | Peta interaktif dengan OpenStreetMap  |
| `latlong2`                   | ^0.9.1  | Handling koordinat latitude/longitude |
| `flutter_map_marker_cluster` | ^1.3.1  | Clustering marker untuk performa      |
| `geolocator`                 | ^14.0.2 | Mendapatkan lokasi user               |

## 📁 Structure

```
lib/features/map/
├── domain/
│   ├── entities/
│   │   └── partner_location.dart      # Entity lokasi mitra
│   ├── repositories/
│   │   └── map_repository.dart        # Interface repository
│   └── usecases/
│       └── get_partner_locations_use_case.dart
├── data/
│   ├── models/
│   │   └── partner_location_model.dart
│   ├── datasources/
│   │   └── map_remote_data_source.dart
│   └── repositories/
│       └── map_repository_impl.dart
└── presentation/
    ├── bindings/
    │   └── map_binding.dart
    ├── controllers/
    │   └── map_controller.dart
    ├── pages/
    │   └── map_page.dart
    └── widgets/
        └── partner_marker.dart
```

## 🗺️ Features

### 1. Interactive Map

- **OpenStreetMap tiles** - Gratis, tanpa API key
- **Zoom & pan** - User dapat zoom dan geser peta
- **Marker clustering** - Marker dikelompokkan saat zoom out
- **User location** - Menampilkan posisi user saat ini

### 2. Partner Markers

- **Color coded** - Biru untuk dokter, hijau untuk perawat
- **Online status** - Indikator hijau untuk mitra online
- **Info popup** - Menampilkan info mitra saat diklik

### 3. Filters

- **Semua** - Tampilkan semua mitra
- **Dokter** - Filter hanya dokter
- **Perawat** - Filter hanya perawat

### 4. Nearby Partners

Card di bottom menampilkan 3 mitra terdekat dengan jarak dari user.

## 🔧 Configuration

### API Integration

Fitur ini menggunakan endpoint:

| Endpoint                      | Method | Deskripsi                            |
| ----------------------------- | ------ | ------------------------------------ |
| `/partners/locations`         | GET    | Semua lokasi mitra                   |
| `/partners/locations/doctors` | GET    | Lokasi dokter                        |
| `/partners/locations/nurses`  | GET    | Lokasi perawat                       |
| `/partners/locations/nearby`  | GET    | Mitra terdekat (dengan query params) |

### Mock Data

Jika API belum tersedia, fitur akan menggunakan mock data:

```dart
[
  PartnerLocation(
    id: '1',
    partnerId: 'doc1',
    partnerType: PartnerType.doctor,
    name: 'Dr. Andi Sp.PD',
    latitude: -6.2088,
    longitude: 106.8456,
    address: 'Jl. Sudirman No. 123, Jakarta',
    isOnline: true,
  ),
  // ... more mock data
]
```

## 📱 Usage

### Navigate to Map

```dart
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

// Navigate to map page
Get.toNamed(AppRoutes.map);
```

### Access from Home

Tombol "Peta" tersedia di service grid pada halaman utama.

## 🎯 Controller Methods

```dart
final controller = Get.find<MapController>();

// Load partner locations
controller.loadPartnerLocations();

// Get user location
controller.getCurrentLocation();

// Move to specific location
controller.moveToLocation(LatLng(-6.2088, 106.8456));

// Move to user location
controller.moveToUserLocation();

// Set filter
controller.setFilter(PartnerType.doctor); // Only doctors
controller.setFilter(null); // All partners

// Get nearest partners
final nearest = controller.getNearestPartners(count: 5);

// Calculate distance (in km)
final distance = controller.calculateDistance(
  controller.currentLocation.value,
  LatLng(-6.2088, 106.8456),
);

// Refresh data
controller.refresh();
```

## 🎨 Customization

### Map Style

Edit di `map_page.dart`:

```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  // Ganti dengan provider lain jika perlu:
  // - https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
  // - https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}
),
```

### Marker Style

Edit di `partner_marker.dart`:

```dart
Widget _buildMarkerWidget(PartnerLocation location) {
  // Customize marker appearance
}
```

### Cluster Style

Edit di `map_page.dart`:

```dart
MarkerClusterLayerOptions(
  builder: (context, markers) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary, // Ganti warna cluster
        borderRadius: BorderRadius.circular(20),
      ),
      // ...
    );
  },
),
```

## 📍 Permissions

### Android

Tambahkan di `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS

Tambahkan di `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi ini membutuhkan akses lokasi untuk menampilkan mitra terdekat.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Aplikasi ini membutuhkan akses lokasi untuk menampilkan mitra terdekat.</string>
```

## 🐛 Troubleshooting

### Map tidak muncul

1. Pastikan koneksi internet aktif
2. Cek URL tile layer
3. Pastikan permission lokasi sudah diberikan

### Lokasi user tidak akurat

1. Pastikan GPS aktif
2. Minta user memberikan permission "Allow all the time" atau "Allow while using app"
3. Gunakan `LocationAccuracy.high` untuk akurasi maksimal

### Marker tidak muncul

1. Cek apakah data lokasi mitra tersedia
2. Pastikan koordinat latitude/longitude valid
3. Cek filter yang aktif

## 📊 API Response Format

```json
{
  "data": [
    {
      "id": "1",
      "partner_id": "doc1",
      "partner_type": "doctor",
      "name": "Dr. Andi Sp.PD",
      "photo_url": "https://example.com/photo.jpg",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "address": "Jl. Sudirman No. 123, Jakarta",
      "is_online": true,
      "last_update": "2024-01-01T10:00:00Z"
    }
  ]
}
```

## 🔄 Future Improvements

- [ ] Turn-by-turn navigation ke lokasi mitra
- [ ] Filter berdasarkan jarak (radius)
- [ ] Filter berdasarkan spesialisasi
- [ ] Real-time tracking untuk mitra yang sedang mobile
- [ ] Offline map support
- [ ] Traffic information
- [ ] Alternative map providers (Google Maps, Mapbox)

---

**Last Updated:** June 10, 2026
