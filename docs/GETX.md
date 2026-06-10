# GetX Documentation

Dokumentasi untuk state management, routing, dan dependency injection menggunakan GetX pada Medic Patient App.

## 📋 Daftar Isi

- [Overview](#overview)
- [Dependency Injection](#dependency-injection)
- [Routing](#routing)
- [State Management](#state-management)
- [Controllers](#controllers)
- [Bindings](#bindings)
- [Best Practices](#best-practices)

## Overview

GetX adalah state management yang ringan dan powerful yang digunakan di project ini untuk:

- **State Management** - Mengelola state UI secara reaktif
- **Routing** - Navigasi antar halaman tanpa context
- **Dependency Injection** - Mengelola lifecycle dependencies

### File Terkait

| File                                 | Deskripsi                         |
| ------------------------------------ | --------------------------------- |
| `lib/main.dart`                      | Entry point dengan GetMaterialApp |
| `lib/core/routes/app_pages.dart`     | Route definitions                 |
| `lib/core/routes/app_routes.dart`    | Route constants                   |
| `lib/core/bindings/app_binding.dart` | Global dependency injection       |

## Dependency Injection

### AppBinding (Global DI)

Semua dependencies di-register di `AppBinding`:

```dart
// lib/core/bindings/app_binding.dart
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Controllers
    Get.put(AppThemeController(), permanent: true);
    Get.put(HomeController(Get.find<GetNursesUseCase>()), permanent: true);

    // Services
    Get.lazyPut<ApiClient>(
      () => ApiClient(storageService: Get.find<StorageService>()),
      fenix: true,
    );

    // Repositories & Use Cases
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );

    // ... more dependencies
  }
}
```

### DI Lifecycle

| Method           | Deskripsi                                 | Use Case                       |
| ---------------- | ----------------------------------------- | ------------------------------ |
| `Get.put()`      | Instance langsung dibuat                  | Singleton, permanent services  |
| `Get.lazyPut()`  | Instance dibuat saat pertama kali diakses | Lazy loading, feature-specific |
| `Get.putAsync()` | Instance dibuat secara async              | Async initialization           |

### Fenix Pattern

`fenix: true` berarti instance akan dibuat ulang jika sudah di-delete:

```dart
Get.lazyPut<ApiClient>(
  () => ApiClient(storageService: Get.find<StorageService>()),
  fenix: true, // Akan dibuat ulang jika di-delete
);
```

### Permanent Services

Services yang harus tetap ada selama aplikasi berjalan:

```dart
// Permanent: true - tidak akan di-delete
Get.put<StorageService>(storageService, permanent: true);
Get.put<MidtransService>(midtransService, permanent: true);
Get.put<AppThemeController>(AppThemeController(), permanent: true);
Get.put<HomeController>(HomeController(...), permanent: true);
```

## Routing

### Route Constants

Definisikan semua route names di `app_routes.dart`:

```dart
// lib/core/routes/app_routes.dart
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String search = '/search';
  static const String nurses = '/nurses';
  static const String doctors = '/doctors';
  static const String doctorConsultation = '/doctor-consultation';
  static const String doctorChat = '/doctor-chat';
}
```

### Route Definitions

Daftarkan semua routes di `AppPages`:

```dart
// lib/core/routes/app_pages.dart
class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(), // Feature-specific binding
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => MedicHomePage(),
    ),
    GetPage(
      name: AppRoutes.doctors,
      page: () => const DoctorPage(),
      binding: DoctorBinding(),
    ),
    // ... more routes
  ];
}
```

### Navigation

#### Basic Navigation

```dart
// Navigate to route
Get.toNamed(AppRoutes.doctors);

// Navigate with arguments
Get.toNamed(AppRoutes.doctorConsultation, arguments: {'doctorId': '123'});

// Navigate and remove all previous routes
Get.offAllNamed(AppRoutes.home);

// Navigate back
Get.back();
```

#### Named Navigation with Parameters

```dart
// Define route with parameter
GetPage(
  name: '/doctor/:id',
  page: () => DoctorDetailPage(),
),

// Navigate with parameter
Get.toNamed('/doctor/123');

// Access parameter in page
final doctorId = Get.parameters['id'];
```

### Initial Route Logic

Tentukan route awal berdasarkan authentication status:

```dart
// lib/main.dart
return GetMaterialApp(
  initialRoute: storageService.hasToken ? AppRoutes.home : AppRoutes.login,
  // ...
);
```

## State Management

### Rx Types (Reactive)

Gunakan `.obs` untuk membuat observable:

```dart
class DoctorController extends GetxController {
  // Observable variables
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Doctor> selectedDoctor = Rxn<Doctor>(); // Nullable

  // Computed values
  RxList<Doctor> get filteredDoctors => doctors.where((d) =>
    d.name.toLowerCase().contains(searchQuery.toLowerCase())
  ).toList().obs;
}
```

### Obx Widget

Gunakan `Obx` untuk auto-rebuild saat data berubah:

```dart
@override
Widget build(BuildContext context) {
  return Obx(() {
    if (controller.isLoading.value) {
      return CircularProgressIndicator();
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return ErrorWidget(controller.errorMessage.value);
    }

    return ListView.builder(
      itemCount: controller.doctors.length,
      itemBuilder: (context, index) {
        final doctor = controller.doctors[index];
        return DoctorCard(doctor: doctor);
      },
    );
  });
}
```

### GetBuilder

Untuk state management yang lebih simple (tanpa reactive):

```dart
class SimpleController extends GetxController {
  int counter = 0;

  void increment() {
    counter++;
    update(); // Notify listeners
  }
}

// In UI
GetBuilder<SimpleController>(
  builder: (controller) {
    return Text('Count: ${controller.counter}');
  },
);
```

## Controllers

### Basic Controller

```dart
// lib/features/doctor/presentation/controllers/doctor_controller.dart
class DoctorController extends GetxController {
  final GetDoctorsUseCase getDoctorsUseCase;

  DoctorController(this.getDoctorsUseCase);

  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    try {
      isLoading(true);
      final result = await getDoctorsUseCase.execute();
      doctors.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
```

### Lifecycle Methods

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Called when controller is first created
    // Initialize data, make API calls, etc.
  }

  @override
  void onReady() {
    super.onReady();
    // Called after onInit and after first build
    // Good for showing dialogs, snackbars, etc.
  }

  @override
  void onClose() {
    // Called when controller is deleted
    // Clean up streams, timers, etc.
    super.onClose();
  }
}
```

## Bindings

### Feature Binding

Setiap feature dapat memiliki binding sendiri:

```dart
// lib/features/auth/presentation/bindings/auth_binding.dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        storageService: Get.find<StorageService>(),
      ),
    );
  }
}
```

### Binding di Route

```dart
GetPage(
  name: AppRoutes.login,
  page: () => const LoginPage(),
  binding: AuthBinding(), // Binding akan di-load saat route dibuka
  // bindingDuration: BindingDuration.idle, // Optional: control lifecycle
),
```

## Best Practices

### 1. Use Permanent for Global Services

```dart
// ✅ Good - Global services should be permanent
Get.put<StorageService>(storageService, permanent: true);
Get.put<AppThemeController>(AppThemeController(), permanent: true);

// ❌ Bad - Will be deleted and recreated
Get.lazyPut<StorageService>(() => StorageService());
```

### 2. Lazy Load Feature Dependencies

```dart
// ✅ Good - Only loaded when needed
Get.lazyPut<DoctorController>(
  () => DoctorController(Get.find<GetDoctorsUseCase>()),
  fenix: true,
);

// ❌ Bad - Loaded immediately even if not used
Get.put<DoctorController>(DoctorController(...));
```

### 3. Dispose Controllers Properly

```dart
class ChatController extends GetxController {
  StreamSubscription? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    _messageSubscription = chatStream.listen((message) {
      // Handle message
    });
  }

  @override
  void onClose() {
    _messageSubscription?.cancel(); // Clean up!
    super.onClose();
  }
}
```

### 4. Use Get.find() Sparingly in UI

```dart
// ❌ Avoid in build method - can cause performance issues
@override
Widget build(BuildContext context) {
  final controller = Get.find<DoctorController>();
  return Text(controller.doctors.length.toString());
}

// ✅ Better - use GetBuilder or Obx
@override
Widget build(BuildContext context) {
  return GetBuilder<DoctorController>(
    builder: (controller) {
      return Text(controller.doctors.length.toString());
    },
  );
}
```

### 5. Organize Controllers by Feature

```
lib/features/doctor/
├── presentation/
│   ├── controllers/
│   │   ├── doctor_controller.dart
│   │   └── doctor_chat_controller.dart
│   ├── bindings/
│   │   └── doctor_binding.dart
│   └── pages/
│       ├── doctor_page.dart
│       └── doctor_chat_page.dart
```

### 6. Use GetxService for Non-Controller Services

```dart
class NotificationService extends GetxService {
  void showNotification(String message) {
    // Show notification
  }
}

// Register service
Get.put(NotificationService(), permanent: true);

// Access service
Get.find<NotificationService>().showNotification('Hello!');
```

### 7. Avoid Context When Possible

```dart
// ❌ Traditional way (needs context)
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage()));

// ✅ GetX way (no context needed)
Get.to(() => DetailPage());
Get.toNamed(AppRoutes.detail);
```

### 8. Use Get.dialog for Dialogs

```dart
// Show loading
Get.dialog(CustomLoadingWidget());

// Show custom dialog
Get.dialog(CustomDialog(
  title: 'Confirm',
  content: 'Are you sure?',
  onConfirm: () => Get.back(result: true),
  onCancel: () => Get.back(result: false),
));

// Close dialog
Get.back();
```

### 9. Snackbar Patterns

```dart
// Success
Get.snackbar(
  'Success',
  'Data saved successfully',
  snackPosition: SnackPosition.TOP,
  backgroundColor: Colors.green,
  colorText: Colors.white,
);

// Error
Get.snackbar(
  'Error',
  'Failed to save data',
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.red,
  colorText: Colors.white,
);

// With action
Get.snackbar(
  'Info',
  'New update available',
  mainButton: TextButton(
    onPressed: () => Get.toNamed(AppRoutes.update),
    child: Text('Update Now'),
  ),
);
```

### 10. Theme Controller Example

```dart
// lib/core/controllers/app_theme_controller.dart
class AppThemeController extends GetxController {
  final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;

  ThemeMode get themeMode => _themeMode.value;

  void toggleTheme() {
    _themeMode.value = _themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    Get.changeThemeMode(_themeMode.value);
  }
}

// In UI
Obx(() => GetMaterialApp(
  themeMode: controller.themeMode,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
));
```

## Common Patterns

### Pattern 1: Load Data on Init

```dart
class MyController extends GetxController {
  final RxList<Item> items = <Item>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading(true);
      final result = await repository.getItems();
      items.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
```

### Pattern 2: Pull to Refresh

```dart
class MyController extends GetxController {
  final RxList<Item> items = <Item>[].obs;
  final RxBool isRefreshing = false.obs;

  Future<void> onRefresh() async {
    try {
      isRefreshing(true);
      final result = await repository.getItems();
      items.assignAll(result);
    } finally {
      isRefreshing(false);
    }
  }
}

// In UI
RefreshIndicator(
  onRefresh: () => controller.onRefresh(),
  child: Obx(() => ListView.builder(
    itemCount: controller.items.length,
    itemBuilder: (context, index) => ItemTile(controller.items[index]),
  )),
);
```

### Pattern 3: Form with Validation

```dart
class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> login() async {
    if (!validateForm()) return;

    try {
      isLoading(true);
      await authRepository.login(
        emailController.text,
        passwordController.text,
      );
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  bool validateForm() {
    if (emailController.text.isEmpty) {
      Get.snackbar('Error', 'Email is required');
      return false;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Password is required');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
```

---

**Last Updated:** June 10, 2026
