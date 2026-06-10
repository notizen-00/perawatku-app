# API Documentation

Dokumentasi untuk API client dan network layer pada Medic Patient App.

## 📋 Daftar Isi

- [Overview](#overview)
- [ApiClient](#apiclient)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

## Overview

API layer pada project ini menggunakan **Dio** sebagai HTTP client dengan implementasi yang mencakup:

- Request/Response interceptors
- Automatic token injection
- Error mapping dan handling
- Debug logging
- Timeout configuration

### File Terkait

| File                                     | Deskripsi                         |
| ---------------------------------------- | --------------------------------- |
| `lib/core/network/api_client.dart`       | Main API client dengan Dio        |
| `lib/core/config/app_config.dart`        | Konfigurasi base URL dan API keys |
| `lib/core/errors/app_exception.dart`     | Custom exception class            |
| `lib/core/services/storage_service.dart` | Token storage service             |

## ApiClient

### Inisialisasi

ApiClient diinisialisasi di `AppBinding` dan di-inject menggunakan GetX:

```dart
// lib/core/bindings/app_binding.dart
Get.lazyPut<ApiClient>(
  () => ApiClient(storageService: Get.find<StorageService>()),
  fenix: true,
);
```

### Konfigurasi

```dart
// lib/core/network/api_client.dart
class ApiClient {
  ApiClient({
    required StorageService storageService,
  })  : _storageService = storageService,
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    // Interceptors setup...
  }
}
```

### Konfigurasi Default

| Parameter        | Value               | Deskripsi                      |
| ---------------- | ------------------- | ------------------------------ |
| `baseUrl`        | `AppConfig.baseUrl` | Base URL API (ngrok untuk dev) |
| `connectTimeout` | 20 seconds          | Timeout koneksi                |
| `receiveTimeout` | 20 seconds          | Timeout response               |
| `Accept`         | `application/json`  | Content type accept            |
| `Content-Type`   | `application/json`  | Content type request           |

## Configuration

### Base URL

Edit di `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String baseUrl = 'https://your-api-url.com';
}
```

### Ngrok Header

Untuk development dengan ngrok, API client otomatis menambahkan header:

```dart
if (AppConfig.shouldUseNgrokHeader) {
  options.headers['ngrok-skip-browser-warning'] = 'true';
}
```

## Usage Examples

### GET Request

```dart
// Inject ApiClient
final apiClient = Get.find<ApiClient>();

// Lakukan GET request
try {
  final response = await apiClient.get('/doctors');
  print(response); // Map<String, dynamic>
} catch (e) {
  print(e); // AppException
}
```

### POST Request

```dart
// POST request dengan body
final response = await apiClient.post(
  '/auth/login',
  data: {
    'email': 'user@example.com',
    'password': 'password123',
  },
);
```

### PATCH Request

```dart
// PATCH request untuk update
final response = await apiClient.patch(
  '/user/profile',
  data: {
    'name': 'Updated Name',
    'phone': '08123456789',
  },
);
```

### Custom Headers

```dart
final response = await apiClient.post(
  '/upload',
  data: {'file': base64Image},
  headers: {
    'Content-Type': 'multipart/form-data',
  },
);
```

## Error Handling

### AppException

API client menggunakan custom exception `AppException`:

```dart
// lib/core/errors/app_exception.dart
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException: $message (Status: $statusCode)';
}
```

### Error Mapping

Dio exceptions di-map ke `AppException` dengan pesan yang user-friendly:

| Dio Exception Type  | User Message                       |
| ------------------- | ---------------------------------- |
| `connectionTimeout` | "Koneksi timeout. Coba lagi."      |
| `sendTimeout`       | "Koneksi timeout. Coba lagi."      |
| `receiveTimeout`    | "Koneksi timeout. Coba lagi."      |
| `connectionError`   | "Tidak bisa terhubung ke server."  |
| Default             | "Terjadi kesalahan pada jaringan." |

### Try-Catch Pattern

```dart
try {
  final response = await apiClient.get('/doctors');
  // Handle success
} on AppException catch (e) {
  // Handle API error
  Get.snackbar('Error', e.message);
} catch (e) {
  // Handle unexpected error
  Get.snackbar('Error', 'Terjadi kesalahan tidak terduga');
}
```

## Best Practices

### 1. Gunakan Repository Pattern

Jangan gunakan ApiClient langsung di UI. Gunakan repository pattern:

```dart
// ❌ Jangan lakukan ini di UI
final apiClient = Get.find<ApiClient>();
final response = await apiClient.get('/doctors');

// ✅ Gunakan repository
final doctors = await repository.getDoctors();
```

### 2. Type Safety

Selalu parse response ke model type-safe:

```dart
// Data source layer
Future<List<Doctor>> getDoctors() async {
  final response = await apiClient.get('/doctors');
  final List<dynamic> data = response['data'] ?? [];
  return data.map((json) => Doctor.fromJson(json)).toList();
}
```

### 3. Handle Null Safety

```dart
final response = await apiClient.get('/user');
final user = response['user'] != null
    ? User.fromJson(response['user'])
    : null;
```

### 4. Use Interceptors for Global Logic

Token injection sudah di-handle di interceptor, jadi tidak perlu manual:

```dart
// ✅ Token otomatis ditambahkan oleh interceptor
final response = await apiClient.get('/protected-endpoint');

// ❌ Jangan manual tambahkan token
final response = await apiClient.get(
  '/protected-endpoint',
  headers: {'Authorization': 'Bearer $token'}, // Tidak perlu!
);
```

### 5. Debug Logging

Logging otomatis aktif di debug mode. Untuk production, logging dimatikan:

```dart
// Di AppConfig
static bool get isDev => kDebugMode;

// Di ApiClient
void _logRequest(RequestOptions options) {
  if (!AppConfig.isDev) return; // Hanya log di debug mode
  // ...
}
```

## Remote Data Source Pattern

Setiap feature memiliki remote data source yang menggunakan ApiClient:

```dart
// lib/features/doctor/data/datasources/doctor_remote_data_source.dart
abstract class DoctorRemoteDataSource {
  Future<List<Doctor>> getDoctors();
  Future<Doctor> getDoctorById(String id);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final ApiClient apiClient;

  DoctorRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Doctor>> getDoctors() async {
    final response = await apiClient.get('/doctors');
    // Parse response...
  }
}
```

## API Endpoints Reference

Berikut adalah endpoints yang digunakan dalam aplikasi:

### Authentication

| Method | Endpoint      | Deskripsi  |
| ------ | ------------- | ---------- |
| POST   | `/auth/login` | Login user |

### Doctors

| Method | Endpoint        | Deskripsi        |
| ------ | --------------- | ---------------- |
| GET    | `/doctors`      | Get all doctors  |
| GET    | `/doctors/{id}` | Get doctor by ID |

### Nurses

| Method | Endpoint       | Deskripsi       |
| ------ | -------------- | --------------- |
| GET    | `/nurses`      | Get all nurses  |
| GET    | `/nurses/{id}` | Get nurse by ID |

### Consultation

| Method | Endpoint                       | Deskripsi               |
| ------ | ------------------------------ | ----------------------- |
| POST   | `/consultations`               | Create consultation     |
| GET    | `/consultations/{id}`          | Get consultation detail |
| POST   | `/consultations/{id}/pay`      | Pay consultation        |
| POST   | `/consultations/{id}/messages` | Send message            |

### Activity

| Method | Endpoint                    | Deskripsi                        |
| ------ | --------------------------- | -------------------------------- |
| GET    | `/activities/consultations` | Get consultation activities      |
| GET    | `/activities/medicines`     | Get medicine purchase activities |
| GET    | `/activities/other`         | Get other activities             |

> **Note:** Endpoints di atas adalah referensi umum. Untuk detail lengkap, lihat implementasi di masing-masing remote data source.

---

**Last Updated:** June 10, 2026
