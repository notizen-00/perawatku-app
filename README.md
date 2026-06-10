# Medic Patient App (Perawatku)

Aplikasi mobile healthcare Flutter untuk manajemen konsultasi pasien dengan dokter dan perawat.

## 📋 Daftar Isi

- [Fitur](#fitur)
- [Tech Stack](#tech-stack)
- [Struktur Project](#struktur-project)
- [Getting Started](#getting-started)
- [Konfigurasi](#konfigurasi)
- [Dokumentasi Tambahan](#dokumentasi-tambahan)

## ✨ Fitur

- **Autentikasi** - Login user dengan token-based authentication
- **Daftar Dokter** - Melihat daftar dokter yang tersedia
- **Daftar Perawat** - Melihat daftar perawat yang tersedia
- **Konsultasi** - Membuat dan mengelola sesi konsultasi dengan dokter
- **Chat** - Komunikasi real-time dengan dokter/perawat
- **Pembayaran** - Integrasi dengan Midtrans Payment Gateway
- **Aktivitas** - Riwayat konsultasi dan pembelian obat
- **Pencarian** - Fitur pencarian dokter/perawat

## 🛠 Tech Stack

| Kategori             | Package              | Versi   | Deskripsi                               |
| -------------------- | -------------------- | ------- | --------------------------------------- |
| **State Management** | `get`                | ^4.7.3  | GetX for state management & routing     |
| **Networking**       | `dio`                | ^5.9.0  | HTTP client untuk API calls             |
| **Payment**          | `midtrans_sdk`       | ^1.2.0  | Midtrans payment gateway                |
| **Storage**          | `shared_preferences` | ^2.5.3  | Local storage untuk token & preferences |
| **Location**         | `geolocator`         | ^14.0.2 | GPS location services                   |
| **Location**         | `geocoding`          | ^4.0.0  | Reverse geocoding                       |

## 📁 Struktur Project

```
lib/
├── main.dart                    # Entry point aplikasi
├── core/                        # Core functionality & shared components
│   ├── bindings/               # Dependency injection bindings
│   │   └── app_binding.dart    # Global DI setup
│   ├── config/                 # Konfigurasi aplikasi
│   │   └── app_config.dart     # Base URL, API keys, environment
│   ├── constants/              # Constants & static values
│   ├── controllers/            # Global controllers
│   │   └── app_theme_controller.dart
│   ├── errors/                 # Error handling & exceptions
│   │   └── app_exception.dart
│   ├── helpers/                # Helper functions
│   ├── network/                # Network layer
│   │   └── api_client.dart     # Dio HTTP client dengan interceptors
│   ├── routes/                 # Routing configuration
│   │   ├── app_pages.dart      # Route definitions
│   │   └── app_routes.dart     # Route names constants
│   ├── services/               # Global services
│   │   ├── midtrans_service.dart
│   │   └── storage_service.dart
│   └── theme/                  # Theme configuration
│       ├── app_theme.dart
│       └── app_colors.dart
│
└── features/                    # Feature modules (Clean Architecture)
    ├── account/                # Account management
    ├── activity/               # Activity history
    │   ├── data/              # Data layer
    │   │   ├── datasources/   # Remote data sources
    │   │   └── repositories/  # Repository implementations
    │   ├── domain/            # Domain layer
    │   │   ├── repositories/  # Repository interfaces
    │   │   └── usecases/      # Business logic use cases
    │   └── presentation/      # UI layer
    │
    ├── auth/                  # Authentication
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── consultation/          # Consultation management
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── doctor/                # Doctor features
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── home/                  # Home screen
    │   ├── controller/
    │   ├── data/
    │   ├── presentation/
    │   ├── screen/
    │   └── widget/
    │
    └── nurse/                 # Nurse features
        ├── data/
        ├── domain/
        └── presentation/
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK >= 3.9.2
- Dart >= 3.9.2
- Android Studio / VS Code
- Emulator atau device fisik

### Installation

1. Clone repository:

```bash
git clone https://github.com/notizen-00/perawatku-app.git
cd medic_patient_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Jalankan aplikasi:

```bash
flutter run
```

## ⚙️ Konfigurasi

### Environment Variables

Konfigurasi aplikasi dapat disesuaikan di `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // Base URL API (menggunakan ngrok untuk development)
  static const String baseUrl = 'https://your-ngrok-url.ngrok-free.app';

  // Midtrans Client Key
  static const String midtransClientKey = String.fromEnvironment(
    'MIDTRANS_CLIENT_KEY',
    defaultValue: 'your-client-key',
  );

  // Midtrans Merchant Base URL
  static const String midtransMerchantBaseUrl = String.fromEnvironment(
    'MIDTRANS_MERCHANT_BASE_URL',
    defaultValue: baseUrl,
  );
}
```

### Mengubah API Base URL

Edit file `lib/core/config/app_config.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### Midtrans Configuration

Untuk mengubah konfigurasi Midtrans, edit di `lib/core/config/app_config.dart` atau passing melalui command line:

```bash
flutter run --dart-define=MIDTRANS_CLIENT_KEY=your-client-key
```

## 📚 Dokumentasi Tambahan

| Dokumen                                            | Deskripsi                                                   |
| -------------------------------------------------- | ----------------------------------------------------------- |
| [API Documentation](docs/API.md)                   | Panduan API client, endpoints, dan error handling           |
| [GetX Documentation](docs/GETX.md)                 | Panduan state management, routing, dan dependency injection |
| [Features Documentation](docs/FEATURES.md)         | Dokumentasi setiap feature module                           |
| [Architecture Documentation](docs/ARCHITECTURE.md) | Clean Architecture pattern yang digunakan                   |

## 🔧 Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Build APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

## 📱 Supported Platforms

- Android (min SDK 21)
- iOS (min iOS 12.0)
- Web
- Windows
- macOS
- Linux

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 📞 Contact

Untuk pertanyaan atau dukungan, silakan hubungi tim development.

---

**Last Updated:** June 10, 2026
