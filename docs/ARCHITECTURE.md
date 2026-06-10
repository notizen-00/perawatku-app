# Architecture Documentation

Dokumentasi untuk Clean Architecture pattern dan struktur project pada Medic Patient App.

## 📋 Daftar Isi

- [Overview](#overview)
- [Clean Architecture](#clean-architecture)
- [Layer Details](#layer-details)
- [Dependency Injection](#dependency-injection)
- [Data Flow](#data-flow)
- [Design Patterns](#design-patterns)
- [Best Practices](#best-practices)

## Overview

Project ini mengikuti **Clean Architecture** pattern yang memisahkan concern menjadi beberapa layer:

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│  (Pages, Widgets, Controllers, Bindings)        │
├─────────────────────────────────────────────────┤
│                Domain Layer                      │
│     (Entities, Repositories, Use Cases)          │
├─────────────────────────────────────────────────┤
│                 Data Layer                       │
│   (Models, Data Sources, Repository Impl)        │
├─────────────────────────────────────────────────┤
│              Infrastructure                      │
│    (API Client, Storage, External Services)      │
└─────────────────────────────────────────────────┘
```

### Principles

1. **Separation of Concerns** - Setiap layer memiliki tanggung jawab spesifik
2. **Dependency Rule** - Dependencies hanya mengarah ke dalam (ke domain)
3. **Testability** - Business logic dapat di-test tanpa UI/database
4. **Independence** - Domain layer tidak bergantung pada framework/UI/database

## Clean Architecture

### Project Structure

```
lib/
├── main.dart                    # Entry point
├── core/                        # Shared infrastructure
│   ├── bindings/               # Global DI
│   ├── config/                 # Configuration
│   ├── constants/              # Constants
│   ├── controllers/            # Global controllers
│   ├── errors/                 # Error handling
│   ├── helpers/                # Utilities
│   ├── network/                # API client
│   ├── routes/                 # Routing
│   ├── services/               # Services
│   └── theme/                  # Theming
│
└── features/                    # Feature modules
    └── [feature_name]/
        ├── data/               # Data layer
        │   ├── datasources/   # API/Local data
        │   ├── models/        # Data models
        │   └── repositories/  # Repository impl
        ├── domain/            # Domain layer
        │   ├── entities/      # Business entities
        │   ├── repositories/  # Repository interface
        │   └── usecases/      # Business logic
        └── presentation/      # Presentation layer
            ├── bindings/      # Feature DI
            ├── controllers/   # State management
            ├── pages/         # Page widgets
            ├── screens/       # Screen widgets
            └── widgets/       # Reusable widgets
```

## Layer Details

### 1. Presentation Layer

Layer UI yang berinteraksi dengan user.

**Responsibilities:**

- Menampilkan UI
- Handle user interactions
- Manage UI state
- Navigate between screens

**Components:**

- `Pages` - Full screen widgets
- `Widgets` - Reusable UI components
- `Controllers` - State management (GetX)
- `Bindings` - Feature-specific DI

**Example:**

```dart
// lib/features/doctor/presentation/pages/doctor_page.dart
class DoctorPage extends GetView<DoctorController> {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.doctors.length,
          itemBuilder: (context, index) {
            return DoctorCard(doctor: controller.doctors[index]);
          },
        );
      }),
    );
  }
}
```

### 2. Domain Layer

Layer business logic yang tidak bergantung pada framework.

**Responsibilities:**

- Define business rules
- Contain use cases
- Define repository interfaces
- Define entities

**Components:**

- `Entities` - Business objects
- `Repositories` - Abstract interfaces
- `UseCases` - Business logic operations

**Example:**

```dart
// lib/features/doctor/domain/entities/doctor.dart
class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String photoUrl;
  final double rating;
  final int consultationFee;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.photoUrl,
    required this.rating,
    required this.consultationFee,
  });
}

// lib/features/doctor/domain/repositories/doctor_repository.dart
abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors();
  Future<Doctor> getDoctorById(String id);
}

// lib/features/doctor/domain/usecases/get_doctors_use_case.dart
class GetDoctorsUseCase {
  final DoctorRepository repository;

  GetDoctorsUseCase(this.repository);

  Future<List<Doctor>> execute() {
    return repository.getDoctors();
  }
}
```

### 3. Data Layer

Layer data access yang menangani pengambilan dan penyimpanan data.

**Responsibilities:**

- Implement repository interfaces
- Fetch data from API/local storage
- Map data to domain entities
- Handle data caching

**Components:**

- `Models` - Data models with JSON serialization
- `DataSources` - API/Local data access
- `Repositories` - Repository implementations

**Example:**

```dart
// lib/features/doctor/data/models/doctor_model.dart
class DoctorModel extends Doctor {
  DoctorModel({
    required String id,
    required String name,
    required String specialization,
    required String photoUrl,
    required double rating,
    required int consultationFee,
  }) : super(
          id: id,
          name: name,
          specialization: specialization,
          photoUrl: photoUrl,
          rating: rating,
          consultationFee: consultationFee,
        );

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      consultationFee: json['consultation_fee'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'photo_url': photoUrl,
      'rating': rating,
      'consultation_fee': consultationFee,
    };
  }
}

// lib/features/doctor/data/datasources/doctor_remote_data_source.dart
abstract class DoctorRemoteDataSource {
  Future<List<DoctorModel>> getDoctors();
  Future<DoctorModel> getDoctorById(String id);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final ApiClient apiClient;

  DoctorRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DoctorModel>> getDoctors() async {
    final response = await apiClient.get('/doctors');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => DoctorModel.fromJson(json)).toList();
  }

  @override
  Future<DoctorModel> getDoctorById(String id) async {
    final response = await apiClient.get('/doctors/$id');
    return DoctorModel.fromJson(response['data']);
  }
}

// lib/features/doctor/data/repositories/doctor_repository_impl.dart
class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  DoctorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Doctor>> getDoctors() async {
    final models = await remoteDataSource.getDoctors();
    return models; // DoctorModel extends Doctor
  }

  @override
  Future<Doctor> getDoctorById(String id) async {
    return await remoteDataSource.getDoctorById(id);
  }
}
```

### 4. Infrastructure (Core)

Layer infrastruktur yang menyediakan shared functionality.

**Components:**

- `ApiClient` - HTTP client
- `StorageService` - Local storage
- `AppConfig` - Configuration
- `AppException` - Error handling
- `AppTheme` - Theming

## Dependency Injection

### Global Binding (AppBinding)

Semua dependencies di-register di `AppBinding`:

```dart
// lib/core/bindings/app_binding.dart
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Global Controllers
    Get.put(AppThemeController(), permanent: true);
    Get.put(HomeController(Get.find<GetNursesUseCase>()), permanent: true);

    // 2. Infrastructure
    Get.lazyPut<ApiClient>(
      () => ApiClient(storageService: Get.find<StorageService>()),
      fenix: true,
    );

    // 3. Data Sources
    Get.lazyPut<DoctorRemoteDataSource>(
      () => DoctorRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    // 4. Repositories
    Get.lazyPut<DoctorRepository>(
      () => DoctorRepositoryImpl(
        remoteDataSource: Get.find<DoctorRemoteDataSource>(),
      ),
      fenix: true,
    );

    // 5. Use Cases
    Get.lazyPut<GetDoctorsUseCase>(
      () => GetDoctorsUseCase(Get.find<DoctorRepository>()),
      fenix: true,
    );
  }
}
```

### Feature Binding

Setiap feature dapat memiliki binding sendiri:

```dart
// lib/features/doctor/presentation/bindings/doctor_binding.dart
class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorController>(
      () => DoctorController(Get.find<GetDoctorsUseCase>()),
    );
  }
}
```

## Data Flow

### Request Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│     UI      │────▶│  Controller │────▶│   UseCase   │
└─────────────┘     └─────────────┘     └──────┬──────┘
       ▲                                        │
       │                                        ▼
       │                               ┌─────────────┐
       │                               │ Repository  │
       │                               └──────┬──────┘
       │                                      │
       │                                      ▼
       │                               ┌─────────────┐
       │                               │ DataSource  │
       │                               └──────┬──────┘
       │                                      │
       │                                      ▼
       │                               ┌─────────────┐
       └───────────────────────────────│  ApiClient  │
                                       └─────────────┘
```

### Example Flow

```dart
// 1. UI triggers action
// In DoctorPage
controller.loadDoctors();

// 2. Controller calls UseCase
class DoctorController extends GetxController {
  final GetDoctorsUseCase getDoctorsUseCase;

  Future<void> loadDoctors() async {
    isLoading(true);
    try {
      final doctors = await getDoctorsUseCase.execute();
      this.doctors.assignAll(doctors);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}

// 3. UseCase calls Repository
class GetDoctorsUseCase {
  final DoctorRepository repository;

  Future<List<Doctor>> execute() {
    return repository.getDoctors();
  }
}

// 4. Repository calls DataSource
class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  @override
  Future<List<Doctor>> getDoctors() async {
    return await remoteDataSource.getDoctors();
  }
}

// 5. DataSource calls ApiClient
class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final ApiClient apiClient;

  @override
  Future<List<DoctorModel>> getDoctors() async {
    final response = await apiClient.get('/doctors');
    // Parse and return
  }
}
```

## Design Patterns

### 1. Repository Pattern

Memisahkan data access dari business logic:

```dart
// Domain defines interface
abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors();
}

// Data implements interface
class DoctorRepositoryImpl implements DoctorRepository {
  @override
  Future<List<Doctor>> getDoctors() async {
    // Implementation
  }
}
```

**Benefits:**

- Domain layer tidak tahu tentang data source
- Mudah switch antara API/Local storage
- Mudah untuk testing (mock repository)

### 2. Use Case Pattern

Setiap use case mewakili satu action:

```dart
class GetDoctorsUseCase {
  final DoctorRepository repository;

  Future<List<Doctor>> execute() {
    return repository.getDoctors();
  }
}

class GetDoctorByIdUseCase {
  final DoctorRepository repository;

  Future<Doctor> execute(String id) {
    return repository.getDoctorById(id);
  }
}
```

**Benefits:**

- Single responsibility
- Reusable
- Testable
- Clear intent

### 3. Dependency Injection

Menggunakan GetX untuk DI:

```dart
// Register
Get.lazyPut<DoctorRepository>(
  () => DoctorRepositoryImpl(remoteDataSource: Get.find<DoctorRemoteDataSource>()),
);

// Use
final repository = Get.find<DoctorRepository>();
```

**Benefits:**

- Loose coupling
- Easy testing
- Centralized configuration

### 4. Reactive Programming

Menggunakan Rx types dari GetX:

```dart
class DoctorController extends GetxController {
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxBool isLoading = false.obs;

  // Auto-rebuild UI when data changes
  Future<void> loadDoctors() async {
    isLoading(true); // UI auto updates
    doctors.assignAll(await getDoctorsUseCase.execute());
    isLoading(false); // UI auto updates
  }
}
```

## Best Practices

### 1. Dependency Direction

```
✅ GOOD: Dependencies point inward
Presentation → Domain → Data

❌ BAD: Dependencies point outward
Data → Domain → Presentation
```

### 2. Entity vs Model

```dart
// Domain uses Entity (pure Dart class)
class Doctor {
  final String id;
  final String name;
  Doctor({required this.id, required this.name});
}

// Data uses Model (with JSON serialization)
class DoctorModel extends Doctor {
  DoctorModel({required String id, required String name})
      : super(id: id, name: name);

  factory DoctorModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 3. Repository Interface in Domain

```dart
// ✅ GOOD: Interface in domain
// lib/features/doctor/domain/repositories/doctor_repository.dart
abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors();
}

// Implementation in data
// lib/features/doctor/data/repositories/doctor_repository_impl.dart
class DoctorRepositoryImpl implements DoctorRepository { ... }
```

### 4. Use Case Single Responsibility

```dart
// ✅ GOOD: One use case per action
class GetDoctorsUseCase { ... }
class GetDoctorByIdUseCase { ... }
class CreateDoctorUseCase { ... }

// ❌ BAD: Multiple actions in one use case
class DoctorUseCase {
  Future<List<Doctor>> getDoctors() { ... }
  Future<Doctor> getDoctorById(String id) { ... }
  Future<Doctor> createDoctor(Doctor doctor) { ... }
}
```

### 5. Error Handling

```dart
// Use custom exceptions
class AppException implements Exception {
  final String message;
  final int? statusCode;
  AppException(this.message, {this.statusCode});
}

// Handle in controller
try {
  final result = await useCase.execute();
} on AppException catch (e) {
  Get.snackbar('Error', e.message);
} catch (e) {
  Get.snackbar('Error', 'Unexpected error');
}
```

### 6. Loading States

```dart
class DoctorController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> loadData() async {
    try {
      isLoading(true);
      // Fetch data
    } finally {
      isLoading(false);
    }
  }
}

// In UI
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  return ContentWidget();
});
```

### 7. Testing

```dart
// Mock repository for testing
class MockDoctorRepository implements DoctorRepository {
  @override
  Future<List<Doctor>> getDoctors() async {
    return [
      Doctor(id: '1', name: 'Dr. John'),
      Doctor(id: '2', name: 'Dr. Jane'),
    ];
  }
}

// Test use case
test('GetDoctorsUseCase returns list of doctors', () async {
  final repository = MockDoctorRepository();
  final useCase = GetDoctorsUseCase(repository);

  final doctors = await useCase.execute();

  expect(doctors.length, 2);
  expect(doctors.first.name, 'Dr. John');
});
```

## File Naming Conventions

| Type                      | Pattern                               | Example                          |
| ------------------------- | ------------------------------------- | -------------------------------- |
| Entity                    | `[name].dart`                         | `doctor.dart`                    |
| Model                     | `[name]_model.dart`                   | `doctor_model.dart`              |
| Repository Interface      | `[name]_repository.dart`              | `doctor_repository.dart`         |
| Repository Implementation | `[name]_repository_impl.dart`         | `doctor_repository_impl.dart`    |
| Data Source               | `[name]_remote_data_source.dart`      | `doctor_remote_data_source.dart` |
| Use Case                  | `[action]_[name]_use_case.dart`       | `get_doctors_use_case.dart`      |
| Controller                | `[name]_controller.dart`              | `doctor_controller.dart`         |
| Page                      | `[name]_page.dart`                    | `doctor_page.dart`               |
| Widget                    | `[name]_widget.dart` or `[name].dart` | `doctor_card.dart`               |
| Binding                   | `[name]_binding.dart`                 | `doctor_binding.dart`            |

---

**Last Updated:** June 10, 2026
