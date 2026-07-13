import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class ProfileCompletionPage extends GetView<AuthController> {
  const ProfileCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FBFA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CompletionHero(),
                const SizedBox(height: 20),
                _CompletionCard(
                  child: Column(
                    children: [
                      Obx(
                        () => _AreaDropdown(
                          value: controller.selectedProvince.value,
                          items: controller.provinces,
                          isLoading: controller.isLoadingProvinces.value,
                          label: 'Provinsi',
                          hint: 'Pilih provinsi',
                          icon: Icons.map_rounded,
                          onChanged: controller.selectProvince,
                          onRefresh: controller.loadProvinces,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => _AreaDropdown(
                          value: controller.selectedRegency.value,
                          items: controller.regencies,
                          isLoading: controller.isLoadingRegencies.value,
                          label: 'Kota/Kabupaten',
                          hint: controller.selectedProvince.value == null
                              ? 'Pilih provinsi dulu'
                              : 'Pilih kota/kabupaten',
                          icon: Icons.location_city_rounded,
                          onChanged: controller.selectedProvince.value == null
                              ? null
                              : controller.selectRegency,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => _AreaDropdown(
                          value: controller.selectedDistrict.value,
                          items: controller.districts,
                          isLoading: controller.isLoadingDistricts.value,
                          label: 'Kecamatan',
                          hint: controller.selectedRegency.value == null
                              ? 'Pilih kota dulu'
                              : 'Pilih kecamatan',
                          icon: Icons.place_rounded,
                          onChanged: controller.selectedRegency.value == null
                              ? null
                              : controller.selectDistrict,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.profileAddressController,
                        minLines: 3,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.home_rounded),
                          labelText: 'Alamat lengkap',
                          hintText: 'Nama jalan, nomor rumah, RT/RW',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.completeProfileAddress,
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text(
                            'Simpan dan Lanjut',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionHero extends StatelessWidget {
  const _CompletionHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_location_alt_rounded, color: Colors.white, size: 38),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lengkapi alamat pasien',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Alamat dibutuhkan agar kami bisa mencarikan mitra terdekat dengan lebih akurat.',
                  style: TextStyle(
                    color: Color(0xDFFFFFFF),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AreaDropdown extends StatelessWidget {
  const _AreaDropdown({
    required this.value,
    required this.items,
    required this.isLoading,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.onRefresh,
  });

  final IndonesiaAreaOption? value;
  final List<IndonesiaAreaOption> items;
  final bool isLoading;
  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<IndonesiaAreaOption?>? onChanged;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final hasItems = items.isNotEmpty;
    final canChange = onChanged != null && !isLoading && hasItems;

    return DropdownButtonFormField<IndonesiaAreaOption>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : !hasItems && onRefresh != null
            ? IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              )
            : null,
      ),
      hint: Text(isLoading ? 'Memuat...' : hint),
      items: items
          .map(
            (item) => DropdownMenuItem<IndonesiaAreaOption>(
              value: item,
              child: Text(item.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: canChange ? onChanged : null,
    );
  }
}
