# Features Documentation

Dokumentasi untuk setiap feature module pada Medic Patient App. Setiap feature diimplementasikan menggunakan Clean Architecture pattern.

## 📋 Daftar Isi

- [Overview](#overview)
- [Auth Feature](#auth-feature)
- [Home Feature](#home-feature)
- [Doctor Feature](#doctor-feature)
- [Nurse Feature](#nurse-feature)
- [Consultation Feature](#consultation-feature)
- [Activity Feature](#activity-feature)
- [Account Feature](#account-feature)

## Overview

### Clean Architecture Pattern

Setiap feature module mengikuti Clean Architecture dengan 3 layer:

```
lib/features/[feature_name]/
├── data/                    # Data Layer
│   ├── datasources/        # Remote/Local data sources
│   ├── models/             # Data models (JSON serialization)
│   └── repositories/       # Repository implementations
├── domain/                  # Domain Layer (Business Logic)
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Use cases
└── presentation/            # Presentation Layer (UI)
    ├── bindings/           # Dependency injection
    ├── controllers/        # Controllers/ViewModels
    ├── pages/              # Page widgets
    ├── widgets/            # Reusable widgets
    └── screens/            # Screen widgets
```

### Feature Dependencies

```
┌─────────────┐
│    Auth     │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│    Home     │────▶│   Doctor    │
└──────┬──────┘     └──────┬──────┘
       │                   │
       ▼                   ▼
┌─────────────┐     ┌─────────────┐
│    Nurse    │     │Consultation │
└─────────────┘     └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  Activity   │
                    └─────────────┘
```

## Auth Feature

Autentikasi user dan manajemen sesi.

### Structure

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_data_source.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── login_use_case.dart
└── presentation/
    ├── bindings/
    │   └── auth_binding.dart
    ├── controllers/
    │   └── auth_controller.dart
    └── pages/
        └── login_page.dart
```

### Key Components

| Component            | File                                            | Deskripsi                  |
| -------------------- | ----------------------------------------------- | -------------------------- |
| LoginUseCase         | `domain/usecases/login_use_case.dart`           | Business logic untuk login |
| AuthRepository       | `domain/repositories/auth_repository.dart`      | Interface repository       |
| AuthRemoteDataSource | `data/datasources/auth_remote_data_source.dart` | API calls untuk auth       |
| AuthController       | `presentation/controllers/auth_controller.dart` | State management           |
| LoginPage            | `presentation/pages/login_page.dart`            | UI halaman login           |

### API Endpoints

| Method | Endpoint      | Deskripsi  |
| ------ | ------------- | ---------- |
| POST   | `/auth/login` | Login user |

### Usage Example

```dart
// Login
final result = await loginUseCase.execute(email, password);
// result: User entity

// Check auth status
if (storageService.hasToken) {
  Get.offAllNamed(AppRoutes.home);
}
```

## Home Feature

Halaman utama aplikasi dengan dashboard.

### Structure

```
lib/features/home/
├── controller/
│   └── home_controller.dart
├── data/
│   └── repositories/
├── presentation/
│   ├── home_page.dart
│   ├── pages/
│   ├── screen/
│   │   └── search_page.dart
│   └── widget/
│       └── home_dashboard_content.dart
└── domain/
```

### Key Components

| Component            | File                                              | Deskripsi                  |
| -------------------- | ------------------------------------------------- | -------------------------- |
| HomeController       | `controller/home_controller.dart`                 | Main controller untuk home |
| MedicHomePage        | `presentation/home_page.dart`                     | Halaman utama              |
| SearchPage           | `presentation/screen/search_page.dart`            | Halaman pencarian          |
| HomeDashboardContent | `presentation/widget/home_dashboard_content.dart` | Dashboard widget           |

### Features

- Dashboard dengan quick actions
- Navigasi ke fitur dokter, perawat, konsultasi
- Search functionality
- Activity summary

## Doctor Feature

Manajemen daftar dokter dan konsultasi.

### Structure

```
lib/features/doctor/
├── data/
│   ├── datasources/
│   │   └── doctor_remote_data_source.dart
│   ├── models/
│   │   └── doctor_model.dart
│   └── repositories/
│       └── doctor_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── doctor.dart
│   ├── repositories/
│   │   └── doctor_repository.dart
│   └── usecases/
│       └── get_doctors_use_case.dart
└── presentation/
    ├── bindings/
    │   ├── doctor_binding.dart
    │   └── doctor_chat_binding.dart
    ├── pages/
    │   ├── doctor_page.dart
    │   ├── doctor_consultation_page.dart
    │   └── doctor_chat_page.dart
    └── widgets/
```

### Key Components

| Component              | File                                               | Deskripsi            |
| ---------------------- | -------------------------------------------------- | -------------------- |
| GetDoctorsUseCase      | `domain/usecases/get_doctors_use_case.dart`        | Get all doctors      |
| DoctorRepository       | `domain/repositories/doctor_repository.dart`       | Repository interface |
| DoctorRemoteDataSource | `data/datasources/doctor_remote_data_source.dart`  | API calls            |
| DoctorPage             | `presentation/pages/doctor_page.dart`              | Daftar dokter        |
| DoctorConsultationPage | `presentation/pages/doctor_consultation_page.dart` | Halaman konsultasi   |
| DoctorChatPage         | `presentation/pages/doctor_chat_page.dart`         | Chat dengan dokter   |

### API Endpoints

| Method | Endpoint        | Deskripsi        |
| ------ | --------------- | ---------------- |
| GET    | `/doctors`      | Get all doctors  |
| GET    | `/doctors/{id}` | Get doctor by ID |

## Nurse Feature

Manajemen daftar perawat.

### Structure

```
lib/features/nurse/
├── data/
│   ├── datasources/
│   │   └── nurse_remote_data_source.dart
│   ├── models/
│   │   └── nurse_model.dart
│   └── repositories/
│       └── nurse_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── nurse.dart
│   ├── repositories/
│   │   └── nurse_repository.dart
│   └── usecases/
│       └── get_nurses_use_case.dart
└── presentation/
    ├── bindings/
    │   └── nurse_binding.dart
    └── pages/
        └── nurse_page.dart
```

### Key Components

| Component             | File                                             | Deskripsi            |
| --------------------- | ------------------------------------------------ | -------------------- |
| GetNursesUseCase      | `domain/usecases/get_nurses_use_case.dart`       | Get all nurses       |
| NurseRepository       | `domain/repositories/nurse_repository.dart`      | Repository interface |
| NurseRemoteDataSource | `data/datasources/nurse_remote_data_source.dart` | API calls            |
| NursePage             | `presentation/pages/nurse_page.dart`             | Daftar perawat       |

### API Endpoints

| Method | Endpoint       | Deskripsi       |
| ------ | -------------- | --------------- |
| GET    | `/nurses`      | Get all nurses  |
| GET    | `/nurses/{id}` | Get nurse by ID |

## Consultation Feature

Manajemen sesi konsultasi dengan dokter.

### Structure

```
lib/features/consultation/
├── data/
│   ├── datasources/
│   │   └── consultation_remote_data_source.dart
│   ├── models/
│   │   └── consultation_model.dart
│   └── repositories/
│       └── consultation_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── consultation.dart
│   ├── repositories/
│   │   └── consultation_repository.dart
│   └── usecases/
│       ├── create_consultation_use_case.dart
│       ├── get_consultation_use_case.dart
│       ├── pay_consultation_use_case.dart
│       └── send_consultation_message_use_case.dart
└── presentation/
    └── pages/
```

### Key Components

| Component                      | File                                                      | Deskripsi               |
| ------------------------------ | --------------------------------------------------------- | ----------------------- |
| CreateConsultationUseCase      | `domain/usecases/create_consultation_use_case.dart`       | Buat konsultasi baru    |
| GetConsultationUseCase         | `domain/usecases/get_consultation_use_case.dart`          | Ambil detail konsultasi |
| PayConsultationUseCase         | `domain/usecases/pay_consultation_use_case.dart`          | Proses pembayaran       |
| SendConsultationMessageUseCase | `domain/usecases/send_consultation_message_use_case.dart` | Kirim pesan             |

### API Endpoints

| Method | Endpoint                       | Deskripsi               |
| ------ | ------------------------------ | ----------------------- |
| POST   | `/consultations`               | Create consultation     |
| GET    | `/consultations/{id}`          | Get consultation detail |
| POST   | `/consultations/{id}/pay`      | Pay consultation        |
| POST   | `/consultations/{id}/messages` | Send message            |

### Payment Flow

1. User membuat konsultasi → `create_consultation_use_case`
2. User melakukan pembayaran → `pay_consultation_use_case` (Midtrans)
3. User bisa chat dengan dokter → `send_consultation_message_use_case`

## Activity Feature

Riwayat aktivitas user.

### Structure

```
lib/features/activity/
├── data/
│   ├── datasources/
│   │   └── activity_remote_data_source.dart
│   ├── models/
│   │   └── activity_model.dart
│   └── repositories/
│       └── activity_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── activity.dart
│   ├── repositories/
│   │   └── activity_repository.dart
│   └── usecases/
│       ├── get_consultation_activities_use_case.dart
│       ├── get_medicine_purchase_activities_use_case.dart
│       └── get_other_activities_use_case.dart
└── presentation/
    └── pages/
```

### Key Components

| Component                            | File                                                             | Deskripsi              |
| ------------------------------------ | ---------------------------------------------------------------- | ---------------------- |
| GetConsultationActivitiesUseCase     | `domain/usecases/get_consultation_activities_use_case.dart`      | Riwayat konsultasi     |
| GetMedicinePurchaseActivitiesUseCase | `domain/usecases/get_medicine_purchase_activities_use_case.dart` | Riwayat pembelian obat |
| GetOtherActivitiesUseCase            | `domain/usecases/get_other_activities_use_case.dart`             | Aktivitas lainnya      |

### API Endpoints

| Method | Endpoint                    | Deskripsi                        |
| ------ | --------------------------- | -------------------------------- |
| GET    | `/activities/consultations` | Get consultation activities      |
| GET    | `/activities/medicines`     | Get medicine purchase activities |
| GET    | `/activities/other`         | Get other activities             |

## Account Feature

Manajemen profil dan akun user.

### Structure

```
lib/features/account/
├── controller/
└── presentation/
```

### Key Components

- Profile management
- Settings
- Logout functionality

## Creating New Features

Untuk menambahkan feature baru, ikuti template berikut:

### 1. Create Domain Layer

```dart
// lib/features/new_feature/domain/entities/entity.dart
class NewEntity {
  final String id;
  final String name;

  NewEntity({required this.id, required this.name});
}

// lib/features/new_feature/domain/repositories/repository.dart
abstract class NewRepository {
  Future<List<NewEntity>> getItems();
}

// lib/features/new_feature/domain/usecases/get_items_use_case.dart
class GetNewItemsUseCase {
  final NewRepository repository;

  GetNewItemsUseCase(this.repository);

  Future<List<NewEntity>> execute() {
    return repository.getItems();
  }
}
```

### 2. Create Data Layer

```dart
// lib/features/new_feature/data/models/model.dart
class NewModel extends NewEntity {
  final String jsonData;

  NewModel({required String id, required String name, required this.jsonData})
      : super(id: id, name: name);

  factory NewModel.fromJson(Map<String, dynamic> json) {
    return NewModel(
      id: json['id'],
      name: json['name'],
      jsonData: json['json_data'],
    );
  }
}

// lib/features/new_feature/data/datasources/remote_data_source.dart
abstract class NewRemoteDataSource {
  Future<List<NewModel>> getItems();
}

class NewRemoteDataSourceImpl implements NewRemoteDataSource {
  final ApiClient apiClient;

  NewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NewModel>> getItems() async {
    final response = await apiClient.get('/new-feature');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => NewModel.fromJson(json)).toList();
  }
}

// lib/features/new_feature/data/repositories/repository_impl.dart
class NewRepositoryImpl implements NewRepository {
  final NewRemoteDataSource remoteDataSource;

  NewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NewEntity>> getItems() async {
    final models = await remoteDataSource.getItems();
    return models; // Models extend Entity
  }
}
```

### 3. Create Presentation Layer

```dart
// lib/features/new_feature/presentation/controllers/controller.dart
class NewController extends GetxController {
  final GetNewItemsUseCase getItemsUseCase;

  NewController(this.getItemsUseCase);

  final RxList<NewEntity> items = <NewEntity>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      isLoading(true);
      final result = await getItemsUseCase.execute();
      items.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}

// lib/features/new_feature/presentation/pages/page.dart
class NewFeaturePage extends GetView<NewController> {
  const NewFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return ListTile(
              title: Text(item.name),
            );
          },
        );
      }),
    );
  }
}

// lib/features/new_feature/presentation/bindings/binding.dart
class NewFeatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewController>(
      () => NewController(Get.find<GetNewItemsUseCase>()),
    );
  }
}
```

### 4. Register in AppBinding

```dart
// lib/core/bindings/app_binding.dart
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // ... existing dependencies

    // New feature
    Get.lazyPut<NewRemoteDataSource>(
      () => NewRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<NewRepository>(
      () => NewRepositoryImpl(remoteDataSource: Get.find<NewRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<GetNewItemsUseCase>(
      () => GetNewItemsUseCase(Get.find<NewRepository>()),
      fenix: true,
    );
  }
}
```

### 5. Add Route

```dart
// lib/core/routes/app_routes.dart
class AppRoutes {
  static const String newFeature = '/new-feature';
}

// lib/core/routes/app_pages.dart
class AppPages {
  static final routes = <GetPage>[
    // ... existing routes

    GetPage(
      name: AppRoutes.newFeature,
      page: () => const NewFeaturePage(),
      binding: NewFeatureBinding(),
    ),
  ];
}
```

---

**Last Updated:** June 10, 2026
